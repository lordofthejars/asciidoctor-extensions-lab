require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'
require "rexml/document" unless RUBY_ENGINE == 'opal'

include ::Asciidoctor

# This extension takes an AsciiDoc document and it generates an Eclipse TOC compliant XML file.
# You can set one attribute: 'eclipsetoc' which is the name of the output html file. By default it is use the docname.
# The Eclipse TOC file is named the value of 'eclipsetoc' attribute or 'docname'.
#
# To run from root directory asciidoctor -r ./lib/eclipse-toc-treeprocessor lib/eclipse-toc-treeprocessor/sample.adoc -a eclipsetoc=ss -o sample.html
#

class EclipseTocTreeprocessor < Extensions::Treeprocessor
  def process document
      
    generated = output_file document
    output = generate_eclipse_toc document, generated
    write_output output, generated
      
    nil
  end
  
  def generate_eclipse_toc document, generated
    
    output = ""
    current_level = 0
    
    ((document.find_by context: :section) || []).each do |sect|
          
        if sect.level == 0
          current_level=0
          section_title = sanitize sect.title
          output = output << "<toc label=\"#{section_title}\">"
        else
          if sect.level <= current_level
            ((current_level - sect.level)+1).times do
              output = output << "</topic>"
            end
          end
          
          current_level = sect.level
          section_title = sanitize sect.title
          output = output << "<topic label=\"#{section_title}\" href=\"#{generated}.html\##{sect.id}\"> "
          
        end
          
      end
      
      current_level.times do
        output = output << "</topic>"
      end
      
      output = output << "</toc>"
  end
  
  def sanitize text
    text.gsub(/<\/?[^>]*>/, "").encode(:xml => :text)
  end
  
  def write_output output, generated
    doc = REXML::Document.new(output)
    formatter = REXML::Formatters::Pretty.new
    formatter.compact = true
      
    File.open("#{generated}.xml", 'w') do |result|
      formatter.write(doc, result)
    end
  end
  
  def output_file document
    if document.attr? 'eclipsetoc'
      generated = document.attr 'eclipsetoc'
    else
      generated = document.attr 'docname'
    end 
  end

end
