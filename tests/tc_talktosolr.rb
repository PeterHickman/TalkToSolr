#!/usr/bin/ruby

require 'test/unit'
require 'talktosolr'

# Open the class do that we can test things without having
# to run a server. In theory all testing could be done with 
# the test_make_url() method but query_q makes it easier to
# test the specifics of the test itself.

class TalkToSolr
  attr_reader :query_q
  
  def test_make_url(extras = {})
    return make_url(extras)
  end
end

class TC_TalkToSolr < Test::Unit::TestCase
  def testSimpleCreate
    sf = TalkToSolrFactory.new('http://www.example.com/')
    s = sf.search('eggs')

    assert_equal(s.describe, '<i>eggs</i> across all data')
    assert_equal(s.query_q, 'content:eggs title:eggs^10')
    assert_equal(s.test_make_url, 'http://www.example.com/select?q=content%3Aeggs+title%3Aeggs%5E10&fq=&fl=%2A%2Cscore&hl=true&hl.fragsize=0&hl.maxAnalyzedChars=2147483647&rows=10&start=0&wt=standard')
    assert_equal(s.fq_as_string, '')
  end

  def testSimpleCreateWithExtras
    sf = TalkToSolrFactory.new('http://www.example.com/')
    s = sf.search('eggs')

    assert_equal(s.describe, '<i>eggs</i> across all data')
    assert_equal(s.query_q, 'content:eggs title:eggs^10')
    assert_equal(s.test_make_url( :wt => 'ruby'), 'http://www.example.com/select?q=content%3Aeggs+title%3Aeggs%5E10&fq=&fl=%2A%2Cscore&hl=true&hl.fragsize=0&hl.maxAnalyzedChars=2147483647&rows=10&start=0&wt=ruby')
    assert_equal(s.fq_as_string, '')
  end

  def testWithAFQParameter
    sf = TalkToSolrFactory.new('http://www.example.com/')
    s = sf.search('eggs', ['place:hailsham'])

    assert_equal(s.describe, "<i>eggs</i> across place: hailsham")
    assert_equal(s.query_q, 'content:eggs title:eggs^10')
    assert_equal(s.test_make_url, 'http://www.example.com/select?q=content%3Aeggs+title%3Aeggs%5E10&fq=%2Bplace%3Ahailsham&fl=%2A%2Cscore&hl=true&hl.fragsize=0&hl.maxAnalyzedChars=2147483647&rows=10&start=0&wt=standard')
    assert_equal(s.fq_as_string, 'place:hailsham')
  end

  def testSortingFQParameter1
    sf = TalkToSolrFactory.new('http://www.example.com/')
    s = sf.search('eggs', ['place:hailsham', 'place:coventry'])

    assert_equal(s.describe, "<i>eggs</i> across place: coventry, hailsham")
    assert_equal(s.query_q, 'content:eggs title:eggs^10')
    assert_equal(s.test_make_url, 'http://www.example.com/select?q=content%3Aeggs+title%3Aeggs%5E10&fq=%2Bplace%3Acoventry+%2Bplace%3Ahailsham&fl=%2A%2Cscore&hl=true&hl.fragsize=0&hl.maxAnalyzedChars=2147483647&rows=10&start=0&wt=standard')
    assert_equal(s.fq_as_string, 'place:hailsham&fq[]=place:coventry')
  end

  def testSortingFQParameter2
    sf = TalkToSolrFactory.new('http://www.example.com/')
    s = sf.search('eggs', ['place:coventry', 'place:hailsham'])

    assert_equal(s.describe, "<i>eggs</i> across place: coventry, hailsham")
    assert_equal(s.query_q, 'content:eggs title:eggs^10')
    assert_equal(s.test_make_url, 'http://www.example.com/select?q=content%3Aeggs+title%3Aeggs%5E10&fq=%2Bplace%3Acoventry+%2Bplace%3Ahailsham&fl=%2A%2Cscore&hl=true&hl.fragsize=0&hl.maxAnalyzedChars=2147483647&rows=10&start=0&wt=standard')
    assert_equal(s.fq_as_string, 'place:coventry&fq[]=place:hailsham')
  end

  def testDifferentFQParameters
    sf = TalkToSolrFactory.new('http://www.example.com/')
    s = sf.search('eggs', ['time:now', 'place:hailsham'])

    assert_equal(s.describe, "<i>eggs</i> across time: now, place: hailsham")
    assert_equal(s.query_q, 'content:eggs title:eggs^10')
    assert_equal(s.test_make_url, 'http://www.example.com/select?q=content%3Aeggs+title%3Aeggs%5E10&fq=%2Bplace%3Ahailsham+%2Btime%3Anow&fl=%2A%2Cscore&hl=true&hl.fragsize=0&hl.maxAnalyzedChars=2147483647&rows=10&start=0&wt=standard')
    assert_equal(s.fq_as_string, 'time:now&fq[]=place:hailsham')
  end

  def testMultipleDifferentFQParameters
    sf = TalkToSolrFactory.new('http://www.example.com/')
    s = sf.search('eggs', ['place:hailsham', 'time:then', 'place:coventry', 'time:now'])

    assert_equal(s.describe, "<i>eggs</i> across time: now, then, place: coventry, hailsham")
    assert_equal(s.query_q, 'content:eggs title:eggs^10')
    assert_equal(s.test_make_url, 'http://www.example.com/select?q=content%3Aeggs+title%3Aeggs%5E10&fq=%2Bplace%3Acoventry+%2Bplace%3Ahailsham+%2Btime%3Anow+%2Btime%3Athen&fl=%2A%2Cscore&hl=true&hl.fragsize=0&hl.maxAnalyzedChars=2147483647&rows=10&start=0&wt=standard')
    assert_equal(s.fq_as_string, 'place:hailsham&fq[]=time:then&fq[]=place:coventry&fq[]=time:now')
  end
  
  def testSymbolsAndStrings
    sf = TalkToSolrFactory.new('http://www.example.com/')
    s1 = sf.search('eggs', [], "start" => 12)
    s2 = sf.search('eggs', [], :start => 12)

    assert_equal(s1.test_make_url, 'http://www.example.com/select?q=content%3Aeggs+title%3Aeggs%5E10&fq=&fl=%2A%2Cscore&hl=true&hl.fragsize=0&hl.maxAnalyzedChars=2147483647&rows=10&start=12&wt=standard')
    assert_equal(s2.test_make_url, 'http://www.example.com/select?q=content%3Aeggs+title%3Aeggs%5E10&fq=&fl=%2A%2Cscore&hl=true&hl.fragsize=0&hl.maxAnalyzedChars=2147483647&rows=10&start=12&wt=standard')
  end
end
