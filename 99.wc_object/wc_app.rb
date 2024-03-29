# frozen_string_literal: true

require 'optparse'
require_relative './text_static'

class FileStat
  def self.display(argv)
    new(argv).display
  end

  def initialize(argv)
    @options, @filenames = extract_options(argv)
  end

  def display
    fetch_wc_files.each do |wc_file|
      text = ''
      text += wc_file.line_count.to_s.rjust(8) if @options[:l] || @options.empty?
      text += wc_file.word_count.to_s.rjust(8) if @options[:w] || @options.empty?
      text += wc_file.byte_count.to_s.rjust(8) if @options[:c] || @options.empty?
      puts "#{text} #{wc_file.name}"
    end
  end

  private

  def extract_options(argv)
    options = {}
    opt = OptionParser.new
    opt.on('-l') { |v| options[:l] = v }
    opt.on('-w') { |v| options[:w] = v }
    opt.on('-c') { |v| options[:c] = v }
    filenames = opt.parse(argv)

    [options, filenames]
  end

  def fetch_wc_files
    if @filenames.empty?
      [Wc.new($stdin.read)]
    else
      wc_files = @filenames.map do |filename|
        file = File.open(filename)
        Wc.new(file.read, file.path)
      end
      wc_files << build_total_wc_file(wc_files) if wc_files.size > 1
      wc_files
    end
  end

  def build_total_wc_file(wc_files)
    total_wc_file_class = Data.define(:line_count, :word_count, :byte_count, :name)
    total_wc_file_class.new(
      line_count: wc_files.sum(&:line_count),
      word_count: wc_files.sum(&:word_count),
      byte_count: wc_files.sum(&:byte_count),
      name: 'total'
    )
  end
end