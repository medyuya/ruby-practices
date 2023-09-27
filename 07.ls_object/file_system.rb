# frozen_string_literal: true

require 'optparse'
require './singular_file_column_group'
require './plural_file_column_group'

SEGMENT_LENGTH = 3

class FileSystem
  def initialize(argv)
    @column_file_groups = create_column_file_groups(argv)
  end

  def display
    puts "total #{@total_blocks}" if @options[:l]
    @column_file_groups.each do |column_file_group|
      puts column_file_group.text
    end
  end

  private

  def create_column_file_groups(argv)
    extract_options(argv)

    filenames = fetch_filenames

    @total_blocks = filenames.sum { |filename| File.stat(filename).blocks }

    if @options[:l]
      filenames.map { |filename| SingularFileColumnGroup.new(filename) }
    else
      divided_filenames = divide_into_segments(filenames)
      longest_filename_length = divided_filenames.flatten.max_by(&:length).length
      transpose(divided_filenames).map { |transposed_filename| PluralFileColumnGroup.new(transposed_filename, longest_filename_length) }
    end
  end

  def extract_options(argv)
    opt = OptionParser.new
    @options = {}
    opt.on('-a') { |v| @options[:a] = v }
    opt.on('-r') { |v| @options[:r] = v }
    opt.on('-l') { |v| @options[:l] = v }
    opt.parse!(argv)
  end

  def fetch_filenames
    filenames = Dir.glob('*')
    filenames = Dir.entries('.') if @options[:a]
    filenames.reverse! if @options[:r]
    filenames
  end

  def divide_into_segments(filenames)
    filenames.each_slice((filenames.length + 2) / SEGMENT_LENGTH).to_a
  end

  def transpose(filenames)
    max_size = filenames.map(&:size).max
    filenames.map! { |items| items.values_at(0...max_size) }
    filenames.transpose
  end
end
