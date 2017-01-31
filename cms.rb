libs = %w(sinatra sinatra/reloader sinatra/content_for tilt/erubis pry yaml bcrypt)
libs.each  { |lib| require lib}
require_relative 'document'


configure do
  set :session_secret, 'secret sauce'
  enable :sessions
  set :erb, :escape_html => true
end

before do
  @documents = []
  if !load_file_data.empty?
    @documents = load_file_data
  end
end

['/:filename/edit', '/:filename/delete', '/file/new'].each do |route|
  before route do
    if !signed_in?
      session[:error] = "You must be signed in to do that"
      redirect "/"
    end
  end
end

def load_accounts
  if ENV["RACK_ENV"] == "test"
    path = File.expand_path("../test/test_user_accounts.yml",__FILE__)
  else
    path = File.expand_path("../user_accounts.yml",__FILE__)
  end
  YAML.load_file(path)
end

ACCOUNTS = load_accounts

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data",__FILE__)
  else
    File.expand_path("../data",__FILE__)
  end
end

def load_file_data
  documents = []
  file_pattern = File.join(data_path, "*")
  Dir[file_pattern].each do |string|
    file_name = File.basename(string)
    path = File.dirname(string)
    doc = Document.load(file_name, path)
    documents << doc
  end
  documents
end

def find_by_name(filename)
  same_names = @documents.reject do |document|
    document.name.downcase != filename.downcase
  end
  same_names.first
end

def signed_in?
  session[:username]
end


def valid_login?(username, password)
  return ACCOUNTS.has_key?(username) && BCrypt::Password.new(ACCOUNTS[username]) == password
end

get "/users/signin" do
  if signed_in?
    redirect "/"
  else
    erb :sign_in
  end
end

post "/users/signin" do
  @username = params[:username]
  password = params[:password]
  if valid_login?(@username,password)
    session[:username] = @username
    session[:success] = "Welcome!"
    redirect "/"
  else
    session[:error] = "Invalid Credentials"
    @username = params[:username]
    erb :sign_in
  end
end

#log user out
post "/users/signout" do
  session[:username] = nil
  session[:success] = "You have been signed out"
  redirect "/"
end

get "/" do
  erb :index
end

#View file content
get "/:filename" do
  document = find_by_name(params[:filename])
  if document
    headers["Content-Type"] = document.format_content[:headers][:content_type]
    document.format_content[:body]
  else
    session[:error] = "#{params[:filename]} does not exist."
    redirect '/'
  end
end

#Render the edit file page
get "/:filename/edit" do
  @document = find_by_name(params[:filename])
  erb :edit_document
end

# # Update/edit page information
post "/:filename/edit" do
  @document = find_by_name(params[:filename])
  @document.update_content(params[:file_content])
  session[:success] = "#{params[:filename]} has been updated."
  redirect "/"
end

#Render the new file page
get "/file/new" do
  @valid_file_types = Document::VALID_FILE_TYPES
  erb :new_document
end

#Create new file page
post "/file/new" do
  @valid_file_types = Document::VALID_FILE_TYPES
  @file_name_base = params[:doc_name].strip
  extension = params[:file_type]
  full_file_name = @file_name_base.strip + "." + extension
  error = nil

  doc = Document.create_document(full_file_name, data_path)
  if find_by_name(full_file_name)
    error = "File name must be unique"  
  elsif doc.error
    error = doc.error  
  end
  
  if error
    session[:error] = error
    status 422
    @file_name_base
    erb :new_document
  else   
    @documents << doc
    session[:success] = "#{full_file_name} has been created."
    redirect "/"
  end
end

#Delete a file
post "/:filename/delete" do
  filename = params[:filename]
  doc = find_by_name(filename)

  doc.delete_file
  @documents.delete(doc)
  session[:success] = "#{filename} was deleted"
  redirect "/"
end