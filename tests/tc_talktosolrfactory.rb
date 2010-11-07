#!/usr/bin/ruby

require 'test/unit'
require 'talktosolr'

# Open the class up so we can make sure that the
# common parameters are being set up correctly

class TalkToSolrFactory
  attr_reader :common
end

class TC_TalkToSolrFactory < Test::Unit::TestCase
  def testSimpleCreate
    sf = TalkToSolrFactory.new('http://www.example.com/')
    s = sf.search('eggs')
  
    assert_equal(s.class, TalkToSolr)
  end

  def testDistinctTalkToSolres
    sf = TalkToSolrFactory.new('http://www.example.com/')
    s1 = sf.search('eggs')
    s2 = sf.search('eggs')
  
    assert_equal(s1.class, TalkToSolr)
    assert_equal(s2.class, TalkToSolr)
    assert_not_equal(s1, s2)
  end

  def testModifiedDefaultParameter
    sf1 = TalkToSolrFactory.new('http://www.example.com/')
    sf2 = TalkToSolrFactory.new('http://www.example.com/', :wt => 'ruby')
    
    sf1.common.each do |k,v|
      if k != "wt"
        assert_equal(sf2.common[k], v)
      end
    end
    
    assert_not_equal(sf1.common["wt"], sf2.common["wt"])
    assert_equal(sf2.common["wt"], 'ruby')
  end

  def testAdditionalParameter
    sf1 = TalkToSolrFactory.new('http://www.example.com/')
    sf2 = TalkToSolrFactory.new('http://www.example.com/', :other => 'other')
    
    sf1.common.each do |k,v|
      assert_equal(sf2.common[k], v)
    end
    
    assert_equal(sf1.common.size + 1, sf2.common.size)
  end
end
