execute 'source ' . expand('<sfile>:p:h') . '/utilities.vim'
execute 'source ' . expand('<sfile>:p:h') . '/query.vim'

"GLOBAL: g:pipeline_uri_label_dictionary 
"This global stores all of the uris for pipelines in Anzo
"along with their human readable label
g:pipeline_uri_label_dictionary 

"FUNCTION: DisplayAllPipelines
"Gathers all pipelines currently 
"in Anzo and displays them in a vertical
"pane 
function vimanzo#spark#DisplayAllPipelines()
  l:query = "SELECT DISTINCT ?pipeline (SAMPLE(?title) as ?label) WHERE { ?pipeline a <http://cambridgesemantics.com/ontologies/ETL#Project> ; dc:title ?title } GROUP BY ?pipeline" 
  let l:raw_info = vimanzo#query#ExecuteQueryFromString(l:query, "-a", "")
  let l:csv = vimanzo#utilities#ParseStringToCSV(l:raw_info)
endfunction
