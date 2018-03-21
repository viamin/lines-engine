# Provides the CRUD operations for +Article+.
# Also handles base64 encoded file uploads and toggling of
# published and featured state of an +Article+
#
# Inherits from +Admin::ApplicationController+ to ensure authentication.

require_dependency 'lines/admin/application_controller'

module Lines
  module Admin
    class ArticlesController < ApplicationController
      autocomplete :tag, :name, class_name: 'ActsAsTaggableOn::Tag'
      before_action :process_base64_upload, only: %i[create update]

      # Lists all articles. Provides <tt>@articles_unpublished</tt> and
      # <tt>@articles_published</tt> to distinguish between published and
      # unpublished articles
      def index
        @articles = Article.order('published ASC, published_at DESC, created_at DESC').page(params[:page]).per(25)
        @articles_unpublished = @articles.select { |a| a.published == false }
        @articles_published = @articles.select { |a| a.published == true }
        respond_to do |format|
          format.html # index.html.erb
        end
      end

      # GET /admin/articles/1
      def show
        @article = Article.friendly.find(params[:id])
        @first_page = true

        respond_to do |format|
          format.html { render :show, layout: 'lines/preview' }
        end
      end

      # GET /admin/articles/new
      def new
        @article = Lines::Article.new

        respond_to do |format|
          format.html # new.html.erb
        end
      end

      # GET /admin/articles/1/edit
      def edit
        @article = Article.friendly.find(params[:id])
      end

      # POST /admin/articles
      def create
        @article = Article.new(article_params)

        respond_to do |format|
          if @article.save
            format.html { redirect_to admin_article_path(@article) }
          else
            format.html { render action: 'new' }
          end
        end
      end

      # PUT /admin/articles/1
      # TODO: Very much is happening here. Move deletion of hero_image to the article model
      def update
        @article = Article.friendly.find(params[:id])
        a_params = article_params

        # replace picture_path with the new uploaded file
        a_params[:hero_image] = @uploaded_file if @uploaded_file

        # delete uploaded hero image when predifined image is selected
        if !a_params[:hero_image_cache].present? && a_params[:short_hero_image].present?
          @article.remove_hero_image!
          @article.remove_hero_image = true
          @article.save
        end

        respond_to do |format|
          if @article.update_attributes(article_params)
            ActionController::Base.new.expire_fragment(@article)
            format.html { redirect_to admin_article_path(@article) }
          else
            format.html { render action: 'edit' }
          end
        end
      end

      # DELETE /admin/articles/1
      def destroy
        @article = Article.friendly.find(params[:id])
        @article.destroy

        respond_to do |format|
          format.html { redirect_to admin_articles_url }
        end
      end

      # Toggles published state of an article
      def toggle_publish
        @article = Article.friendly.find(params[:article_id])
        @article.update_attributes(published: !@article.published)
        flash[:success] = "“#{@article.title}” has been #{'un' unless @article.published}published."
        redirect_to admin_articles_url
      end

      # Toggles featured state of an article
      def toggle_feature
        @article = Article.friendly.find(params[:article_id])
        old_featured = Article.where(featured: true)
        unless old_featured.empty?
          old_featured.each do |article|
            article.update_attributes(featured: false)
          end
        end
        @article.update_attributes(featured: !@article.featured)
        redirect_to admin_articles_url
      end

      # Handles base64 encoded file uploads
      def process_base64_upload
        @uploaded_file = nil
        # check if file is given
        return unless params[:article][:hero_image_file] != ''

        picture_filename = 'hero_image'
        picture_original_filename = 'hero_image'
        # raise params[:article][:hero_image_file].inspect
        picture_content_type = splitBase64(params[:article][:hero_image_file])[:type]
        picture_data = splitBase64(params[:article][:hero_image_file])[:data]

        # create a new tempfile named fileupload
        tempfile = Tempfile.new('fileupload')
        tempfile.binmode

        # get the file and decode it with base64 then write it to the tempfile
        tempfile.write(Base64.decode64(picture_data))

        # create a new uploaded file
        @uploaded_file = ActionDispatch::Http::UploadedFile.new(
          tempfile: tempfile,
          filename: picture_filename,
          original_filename: picture_original_filename
        )
        @uploaded_file.content_type = picture_content_type
      end

      def splitBase64(uri)
        return unless uri =~ /^data:(.*?);(.*?),(.*)$/
        {
          type:      Regexp.last_match(1), # "image/png"
          encoder:   Regexp.last_match(2), # "base64"
          data:      Regexp.last_match(3), # data string
          extension: Regexp.last_match(1).split('/')[1] # "png"
        }
      end

      private

      # Allowed attribute with strong_params
      def article_params
        params.require(:article).permit(:content, :teaser, :hero_image, :short_hero_image, :published,
                                        :published_at, :sub_title, :title, :hero_image_cache, :tag_list, :gplus_url, :featured,
                                        :document, :document_cache, :hero_image_file, :remove_document, :remove_hero_image, :pictures,
                                        pictures_attributes: %i[id image name article_id], author_ids: [])
      end
    end
  end
end
