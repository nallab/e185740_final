# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update destroy]
  skip_before_action :verify_authenticity_token

  # GET /posts or /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1 or /posts/1.json
  def show; end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit; end

  # POST /posts or /posts.json
  def create
    file = params[:file]
    path = file.tempfile.path
    original_file_name = file.original_filename
    upload_dir = Rails.root.join('public', 'cache_files')
    upload_file_path = upload_dir + original_file_name
    File.binwrite(upload_file_path, file.read)
    respond_to do |format|
      if params[:number].present? && params[:merge_file].present?
        number = params[:number].to_i
        array = Dir.glob("#{upload_dir}/#{params[:sort_file]}*")
        if number != array.count
          format.html { redirect_to post_url(1), notice: 'File in the making ' }
          format.json { render :show, status: :created }
        else
          merge_files(array, "#{upload_dir}/#{params[:merge_file]}")
          format.html { redirect_to post_url(1), notice: 'Post was successfully created.' }
          format.json { render :show, status: :created }
          original_file_name = params[:merge_file]
          upload_file_path = "#{upload_dir}/#{params[:merge_file]}"
          thread(upload_file_path, original_file_name)
        end
      else
        format.html { redirect_to post_url(1), notice: 'Post was successfully created.' }
        format.json { render :show, status: :created }
        thread(upload_file_path, original_file_name)
      end
      #   else
      #     format.html { render :new, status: :unprocessable_entity }
      #     format.json { render json: @post.errors, status: :unprocessable_entity }
      #   end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to post_url(@post), notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    # @post = Post.find(params[:id])
  end

  def merge_files(file_array, to_path)
    puts file_array
    file_array.uniq.sort.each_with_index do |file_path, file_i|
      open(file_path, 'rb').each_line.with_index do |row, row_i|
        open(to_path, 'a') { |f| f << row }
      end
      File.delete(file_path)
    end
  end

  def thread(upload_file_path, original_file_name)
    Thread.start do
      @user = User.find_by(id: current_user.id)
      now = Time.now
      expires = Time.parse(@user.expires_in)
      if now > expires
        uri = URI.parse('https://api.dropboxapi.com/oauth2/token')
        req = Net::HTTP::Post.new(uri)
        req.basic_auth(@user.client_id, @user.client_secret)
        req.form_data = { 'grant_type' => 'refresh_token', 'refresh_token' => @user.refresh_token }
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.request(req)
        end

        if res.is_a?(Net::HTTPSuccess)
          res_body = JSON.parse(res.body)
          @user.access_token = res_body['access_token']
          @user.expires_in = (now + res_body['expires_in']).to_s
          @user.save!
        else
          raise "Error: #{res.body}"
        end
      end
      client = DropboxApi::Client.new(
        @user.access_token
      )
      result = ''
      File.open(upload_file_path) do |f|
        result = client.upload_by_chunks "/#{original_file_name}", f
      end
      File.open(upload_file_path) do |f|
        @chunk_size = 4 * 1024 * 1024
        checksum = ''
        loop do
          chunk = f.read(@chunk_size)
          break if chunk.nil?

          sha = Digest::SHA256.digest(chunk)
          checksum += sha
        end

        hash_file = Digest::SHA256.hexdigest(checksum)
        raise 'Error: file broken' if hash_file != result.content_hash
      end
      UserMailer.send_when_succeeded(@user.email, original_file_name).deliver
      File.delete(upload_file_path)
    rescue StandardError => e
      puts e
      UserMailer.send_when_failed(@user.email, original_file_name).deliver
      File.delete(upload_file_path)
    end
  end
  # Only allow a list of trusted parameters through.
  # def post_params
  #   params.require(:post).permit(:title, :body)
  # end

  # def post_params
  #   params.require(:post).permit(:title, :body, :header_image)
  # end

  # # Use a Ruby symbol with brackets (array) for many attachments

  # def post_params
  #   params.require(:post).permit(:title, :body, files: [])
  # end
end
