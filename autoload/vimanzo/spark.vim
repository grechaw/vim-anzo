execute 'source ' . expand('<sfile>:p:h') . '/utilities.vim'
execute 'source ' . expand('<sfile>:p:h') . '/query.vim'

"GLOBAL: g:pipeline_uri_label_dictionary 
"This global stores all of the uris for pipelines in Anzo
"along with their human readable label
g:pipeline_uri_label_dictionary = {}

"FUNCTION: DisplayAllPipelines
"Gathers all pipelines currently 
"in Anzo and displays them in a vertical
"pane 
function vimanzo#spark#getPipelineInfo() 
  let l:select = "SELECT DISTINCT ?pipeline (SAMPLE(?title) as ?label) "
  let l:pipeline_type = "?pipeline a <http://cambridgesemantics.com/ontologies/ETL#Project> ."
  let l:pipeline_title = "?pipeline dc:title ?title ."
  let l:where_clause = " WHERE { " . l:pipeline_type . l:pipeline_title . " } GROUP BY ?pipeline"
  let l:query = l:select . l:where
  let l:result_list = vimanzo#query#internalQuery(l:query, 0, "")
  for l:entry in l:result_list
    let l:key = l:entry["pipeline"]
    let g:pipeline_uri_label_dictionary[l:key] = l:entry[l:label]
  endfor 
endfunction

function FilterBufferByString(filter_string)
  call ":v/" . a:filter_string . "/d"
endfunction 
