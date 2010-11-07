require 'queryparser'
require 'cgi'

class TalkToSolr
  VERSION = '1.0.0'

  attr_reader :error

  def initialize(h, q, fq, p)
    @host = h
    @source_q = q
    @source_fq = fq
    @parameters = p

     @query_fq = nil
     @data = nil
     @error = nil

     @query_q = lucene_query
  end

   def describe
     text = "<i>#{@source_q}</i> across"
     
     if @source_fq.size > 0
       first = true
       describe_fq.each do |k,v|
         if first
           first = false
         else
           text << ","
         end
         text << " #{k}: #{v.sort.join(', ')}"
       end
    else
      text << " all data"
    end
    
    return text
   end

   # Make the actual request and store the data away so that
   # we don't have to make the request more than once.
   def get
      if @data == nil
         url = make_url

      begin
        @data = Net::HTTP.get(URI.parse(url))
      rescue Exception => e
        @error = "Unable to connect to #{url}"
      end
      end

      return @data
   end

   # A special case for the page view, we have an article id
   # so we just get that
   def get_by_id(id)
     if @data == nil
       url = make_url(:fq => "id:#{id}")

        begin
          @data = Net::HTTP.get(URI.parse(url))
        rescue Exception => e
          @error = "Unable to connect to #{url}"
        end
        end
      
      return @data
   end

  def fq_as_string()
    return @source_fq.join('&fq[]=')
  end

  private

   def lucene_query
    if @source_fq.class == Array
      x = Array.new
      @source_fq.sort.each do |i|
        x << "+#{i}"
      end
      @query_fq = x.join(' ')
    end
      
    qp = QueryParser.new('content', nil, { :title => '^10' })
      
      return qp.parse(@source_q)
   end

  def describe_fq
    x = Hash.new

    if @source_fq.class == Array
      @source_fq.each do |i|
        (h, t) = i.split(':')
        if ! x.has_key?(h)
          x[h] = Array.new
        end
        x[h] << t
      end
    end

    return x
  end

   def make_url(extras = {})
      parameters = Array.new

      parameters << "q=#{CGI::escape(@query_q)}"

    if @query_fq
      parameters << "fq=#{CGI::escape(@query_fq)}"
      end

    temp = Hash.new
      @parameters.each do |k,v|
        temp[k.to_s] = v
      end

      extras.each do |k,v|
      temp[k.to_s] = v
     end

    temp.keys.sort.each do |k|
       parameters << "#{k}=#{CGI::escape(temp[k].to_s)}"
      end

      url = "#{@host}select?#{parameters.join('&')}"

      return url
   end
end

class TalkToSolrFactory
   def initialize(host, parameters = {})
      @host = host
      @common = merge_hashes(basics, parameters)
   end

  def search(q, fq = [], args = {})
    new_args = merge_hashes(@common, args)
    return TalkToSolr.new(@host, q, fq, new_args)
  end

  private

  def merge_hashes(a, b)
    x = Hash.new
    
    a.each do |k,v|
      x[k.to_s] = v
    end
    
    b.each do |k,v|
      x[k.to_s] = v
    end
    
    return x
  end

   # Default values (and bug workarounds) for making a search. All these
   # values can be overridden from the second argument to the constructor
  def basics()
    x = {
         'wt' => 'standard',
         'rows' => 10,
         'start' => 0,
         'fl' => '*,score',
         'hl' => 'true',
         'hl.maxAnalyzedChars' => 2147483647,
         'hl.fragsize' => 0
      }

      return x
   end
end
