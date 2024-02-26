# frozen_string_literal: true

require 'optparse'
require_relative 'file_count_result'

class FileStatsAnalyzer
  def initialize
    extract_options
    @original_argv = ARGV.dup
    validate_files_accessible
  end

  def display
    calc_file_stats_results.each do |file|
      puts file.text
    end
  end

  private

  def extract_options
    opt = OptionParser.new
    @options = {}
    opt.on('-a') { |v| @options[:a] = v }
    opt.on('-r') { |v| @options[:r] = v }
    opt.on('-l') { |v| @options[:l] = v }
    opt.parse!(ARGV)
  end

  def validate_files_accessible
    unless ARGF
      puts '指定のファイルは存在しません'
      exit
    end

    return if all_files_exist?

    puts '指定のファイルは存在しません'
    exit
  end

  def all_files_exist?
    @original_argv.all? { |filename| File.exist?(filename) }
  end

  def calc_file_stats_results
    file_metadata = { line_count: 0, word_count: 0, byte_count: 0, name: '' }
    total_stats = { line_count: 0, word_count: 0, byte_count: 0 }
    file_result_stats = []

    ARGF.each do |line|
      file_metadata[:line_count] += 1
      file_metadata[:word_count] += line.split.size
      file_metadata[:byte_count] += line.bytesize

      total_stats[:line_count] += 1
      total_stats[:word_count] += line.split.size
      total_stats[:byte_count] += line.bytesize

      next unless ARGF.eof?

      file_metadata[:name] = ARGF.filename if @original_argv.size.positive?
      file_result_stats << file_metadata
      file_metadata = { line_count: 0, word_count: 0, byte_count: 0, name: '' }

      ARGF.close

      break if ARGF.argv.empty?
    end

    file_result_stats << total_stats if @original_argv.size > 1
    file_result_stats = file_result_stats.map { |file_result_stat| FileCountResult.new(file_result_stat, @options) }
  end
end
