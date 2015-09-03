RUBY_ENGINE == 'opal' ? (require 'eclipse-toc-treeprocessor/extension') : (require_relative 'eclipse-toc-treeprocessor/extension')

Extensions.register do
  treeprocessor EclipseTocTreeprocessor
end
