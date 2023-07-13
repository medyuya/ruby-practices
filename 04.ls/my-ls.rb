#!/usr/bin/env ruby

# frozen_string_literal: true

require 'debug'

SEGMENT_LENGTH = 3

def divide_into_segments(entities)
  entities.each_slice((entities.length + 2) / SEGMENT_LENGTH).to_a
end

def transpose(entities)
  max_size = entities.map(&:size).max
  entities.map! { |items| items.values_at(0...max_size) }
  entities.transpose
end

divided_entities = divide_into_segments(Dir.glob('*'))

longest_entity_length = divided_entities.flatten.max_by { |element| element.length }.length

transposed_entities = transpose(divided_entities)

transposed_entities.each do |column_entitites|
  column_entitites.each do |column_entitiy|
    print column_entitiy&.ljust(longest_entity_length + 1)
  end
  print("\n")
end