module BacktickCodeBlock
  class << self
    AllOptions = /([^\s]+)\s+(.+?)(https?:\/\/\S+)\s*(.+)?/i
    LangCaption = /([^\s]+)\s*(.+)?/i

    def registered(app)
      # print app.methods
      app.before_render do |content, renderer|
    require 'pp'
    pp app
    print Middleman::CoreExtensions::ExternalHelpers.inspect
    # replacement = BacktickCodeBlock.render_code_block(content)
    # content.replace(replacement)
    # content.sub!('Ubuntu', 'Ubuntu LOL !!!!')
      end
    end

    def render_code_block(input)
      @options = nil
      @caption = nil
      @lang = nil
      @url = nil
      @title = nil
      input.gsub(/^`{3} *([^\n]+)?\n(.+?)\n`{3}/m) do
        @options = $1 || ''
        str = $2

        if @options =~ AllOptions
          @lang = $1
          @caption = "<figcaption><span>#{$2}</span><a href='#{$3}'>#{$4 || 'link'}</a></figcaption>"
        elsif @options =~ LangCaption
          @lang = $1
          @caption = "<figcaption><span>#{$2}</span></figcaption>"
        end

        if str.match(/\A( {4}|\t)/)
          str = str.gsub(/^( {4}|\t)/, '')
        end
        if @lang.nil? || @lang == 'plain'
          code = tableize_code(str.gsub('<','&lt;').gsub('>','&gt;'))
          "<figure class='code'>#{@caption}#{code}</figure>"
        else
          if @lang.include? "-raw"
            raw = "``` #{@options.sub('-raw', '')}\n"
            raw += str
            raw += "\n```\n"
          else
            code = self.block_code(str, @lang)
            "<figure class='code'>#{@caption}#{code}</figure>"
          end
        end
      end
    end

    def tableize_code(str, lang = '')
      table = '<div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers">'
      code = ''
      str.lines.each_with_index do |line,index|
        table += "<span class='line-number'>#{index+1}</span>\n"
        code  += "<span class='line'>#{line}</span>"
      end
      table += "</pre></td><td class='code'><pre><code class='#{lang}'>#{code}</code></pre></td></tr></table></div>"
    end

    alias :included :registered
  end
end

::Middleman::Extensions.register(:backtick_code_block, BacktickCodeBlock) 





# module BacktickCodeBlock
#   AllOptions = /([^\s]+)\s+(.+?)(https?:\/\/\S+)\s*(.+)?/i
#   LangCaption = /([^\s]+)\s*(.+)?/i

#   def render_code_block(input)
#     @options = nil
#     @caption = nil
#     @lang = nil
#     @url = nil
#     @title = nil
#     input.gsub(/^`{3} *([^\n]+)?\n(.+?)\n`{3}/m) do
#       @options = $1 || ''
#       str = $2

#       if @options =~ AllOptions
#         @lang = $1
#         @caption = "<figcaption><span>#{$2}</span><a href='#{$3}'>#{$4 || 'link'}</a></figcaption>"
#       elsif @options =~ LangCaption
#         @lang = $1
#         @caption = "<figcaption><span>#{$2}</span></figcaption>"
#       end

#       if str.match(/\A( {4}|\t)/)
#         str = str.gsub(/^( {4}|\t)/, '')
#       end
#       if @lang.nil? || @lang == 'plain'
#         code = tableize_code(str.gsub('<','&lt;').gsub('>','&gt;'))
#         "<figure class='code'>#{@caption}#{code}</figure>"
#       else
#         if @lang.include? "-raw"
#           raw = "``` #{@options.sub('-raw', '')}\n"
#           raw += str
#           raw += "\n```\n"
#         else
#           code = self.block_code(str, @lang)
#           "<figure class='code'>#{@caption}#{code}</figure>"
#         end
#       end
#     end
#   end

#   def tableize_code(str, lang = '')
#     table = '<div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers">'
#     code = ''
#     str.lines.each_with_index do |line,index|
#       table += "<span class='line-number'>#{index+1}</span>\n"
#       code  += "<span class='line'>#{line}</span>"
#     end
#     table += "</pre></td><td class='code'><pre><code class='#{lang}'>#{code}</code></pre></td></tr></table></div>"
#   end
# end

# module Middleman::Renderers
#   class RedcarpetTemplate < ::Tilt::RedcarpetTemplate::Redcarpet2
#       include ::BacktickCodeBlock
#       include Middleman::Syntax::MarkdownCodeRenderer

#       def render(*args)
#           @data = render_code_block(@data)
#           super(*args)
#       end
#   end
# end