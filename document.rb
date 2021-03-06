require "redcarpet"
require "fileutils"

class Document
  attr_reader :name, :file_path, :raw_content, :file_type, :size, :error

  VALID_FILE_TYPES = {
    #keys: file types app can process; 
    #values: full word string representation of file type
    txt: "text",
    md: "markdown"
  }

  def self.create_document(name, file_path)
    doc = Document.new
    doc.valid_name_error(name.split('.').first)
    if doc.error.nil?
      doc.create_document(name, file_path)
    end
    doc
  end

  def self.load(name, file_path)
    doc = Document.new
    doc.load(name, file_path)
    doc
  end

  def valid_name_error(filename)
    if !(1..20).cover?(filename.size)
      @error = "File name must be between 1 and 20 characters"
    elsif (filename =~ /(^[A-Za-z][A-Za-z0-9_]+)$/).nil?
      @error = "Invalid file name.  File must begin with an alpha character.  The rest of the file name can only contain alphanumeric characters and underscores"
    end
    nil
  end
  
  def load(name, file_path)
    @name = name
    @file_path = file_path
    @raw_content = File.open(document_path).read
    @size = compute_size
  end

  def create_document(name, file_path)
    @name = name
    @file_path = file_path
    new_file = File.open(document_path, "w")
    new_file.close
  end

  def format_file_size
    case 
    when (0...2**10).cover?(@size)
      "#{@size} bytes"
    when (2**10...2**20).cover?(size)
      "#{'%.2f' % (Float(@size)/2**10)} KB"
    when (2**20...2**30).cover?(size)
      "#{'%.2f' % (Float(@size)/2**20)} MB"
    when (2**30...2**40).cover?(size)
      "#{'%.2f' % (Float(@size)/2**30)} GB"
    else
      "> TB"
    end
  end

  def format_file_type
    type = @name.split(".")[1].to_sym
    VALID_FILE_TYPES[type]
  end

  def format_content
    formatted_data = {}

    extension = @name.split('.')[1]
    if extension == "md"
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      formatted_data[:headers] = {content_type: "text/html"}
      formatted_data[:body] = markdown.render(@raw_content)
    elsif extension == "txt"
      formatted_data[:headers] = {content_type: "text/plain"}
      formatted_data[:body] = @raw_content
    end
    formatted_data
  end

  def delete_file
    FileUtils.rm(document_path)
  end

  def update_content(content)
    @raw_content = content
    File.write(document_path, @raw_content)
  end

  private


  def compute_size
    File.size(document_path)
  end

  def document_path
    File.join(@file_path, @name)
  end
end