#!/usr/bin/env ruby

##
# get a random word to search on
##

require 'random-word'

module Word
  def self.get_word
  	searchword = RandomWord.adjs.next
    if searchword.include?('_')
      searchword.sub('_', ' ')
    end
    return searchword
  end
end