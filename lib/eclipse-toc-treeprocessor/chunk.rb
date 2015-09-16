require 'asciidoctor'
require 'optparse'

class ChunkDocuments

  def initialize depth
    @documents = []
    @max_depth = depth
  end
  
  def split_document node
    puts "before section"
    node.blocks.each {|b| 
      if b.context == :section
        section b
        #target is docfile
        #output is docdir
      end
    }
    puts "after section"
    write_chunk node.attributes['docdir'], node.attributes['docfile']
    node.blocks.clear
  end
  
  def section node
    doc = node.document
    attributes = {}
    doc.attributes.each do |k, v|
      attributes[k] = v
    end
    attributes['noheader'] = ''
    attributes['doctitle'] = node.title
    attributes['backend'] = 'html5'
    page = Asciidoctor::Document.new [], :header_footer => true, :doctype => doc.doctype, :safe => doc.safe, :parse => true, :attributes => attributes
    page.set_attr 'docname', node.id
    # TODO recurse
    #node.parent = page
    #node.blocks.each {|b| b.parent = node }
    reparent node, page

    # NOTE don't use << on page since it changes section number
    
    if node.level == @max_depth
      page.blocks << node
    elsif node.level < @max_depth
      node.blocks.each do |block|
        if block.context == :section
          section block
        else
          page.blocks << block
        end
      end
    end
    
    @documents << page  
    ''
  end
  
  def write_chunk output, target
    outdir = ::File.dirname target
    bn = ::File.basename target, '.*'
    @documents.each do |doc|
      outfile = ::File.join outdir, %(#{bn}#{doc.attr 'docname'}.html)
      ::File.open(outfile, 'w') do |f|
        f.write doc.convert
      end
    end
  end
  
  def reparent node, parent
    node.parent = parent
    node.blocks.each do |block|
      reparent block, node unless block.context == :dlist
      if block.context == :table
        block.columns.each do |col|
          col.parent = col.parent
        end
        block.rows.body.each do |row|
          row.each do |cell|
            cell.parent = cell.parent
          end
        end
      end
    end
  end
  
end
