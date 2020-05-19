execute 'source ' . expand('<sfile>:p:h') . '/query.vim'

"GLOBAL: g:etl_engine_uri
"This global hols the URI for the etl engine 
"that is used for running pipelines

let g:etl_engine_uri = "http://cambridgesemantics.com/Sparkler_Engine_Config/82965bd0f44911e9a7132a2ae2dbcce4"

if !exists("g:etl_engine_uri")
  let g:etl_engine_uri = input("Enter the URI of your ETL Engine, e.g. spark, sparkler: ")
  echom "If you do not want to use this dialog again uncomment the line let g:etl_engine_uri = \"\" in pipelines.vim and replace \"\" with your preferred ETL engine URI"
endif

"GLOBAL: g:pipeline_uri_label_dictionary 
"This global stores all of the uris for pipelines in Anzo
"along with their human readable label
let g:pipeline_uri_label_dictionary = {}


"FUNCTION: GetPipelineInfo
"Gathers all pipelines currently 
"in Anzo and displays them in a vertical
"pane 
function! vimanzo#pipelines#getPipelineInfo() 
  let l:select = "SELECT DISTINCT ?pipeline (SAMPLE(?title) as ?label) "
  let l:pipeline_type = "?pipeline a <http://cambridgesemantics.com/ontologies/ETL#Project> ."
  let l:pipeline_title = "?pipeline dc:title ?title ."
  let l:where_clause = " WHERE { " . l:pipeline_type . l:pipeline_title . " } GROUP BY ?pipeline"
  let l:query = l:select . l:where_clause
  let l:result_list = vimanzo#query#queryForVimInternal(l:query, 0, "")
  for l:entry in l:result_list
    let l:key = l:entry["pipeline"]
    let g:pipeline_uri_label_dictionary[l:key] = l:entry["label"]
  endfor 
endfunction

"FUNCTION: DisplayPipelines 
"This displays all the pipelines currently in Anzo in a left vertical buffer.
function! vimanzo#pipelines#DisplayPipelinesForRun()
  call vimanzo#pipelines#getPipelineInfo()
  call vimanzo#utilities#CreateNewTab(g:pipeline_uri_label_dictionary, "pipelines", "Pipelines") 
  "Ensure that we have the right indentation on the pipelines page
  execute ":%norm I  "
  execute ":normal gg"
endfunction 

"FUNCTION: GenerateBindings
"This function creates the bindings for the special pane to run pipelines
"When the string "piplines" is passed to CreateNewTab, the call to this 
"function is generated.
function! vimanzo#pipelines#GenerateBindings()
  silent execute ":nnoremap <buffer> m :call vimanzo#pipelines#ToggleMarkPipeline() <CR>"
  silent execute ":nnoremap <buffer> f :call vimanzo#pipelines#FilterBufferByString() <CR>"
  silent execute ":nnoremap <buffer> x :call vimanzo#pipelines#RunSelectedPipelines() <CR>"
  silent execute ":nnoremap <buffer> <CR> :call vimanzo#pipelines#RunSelectedPipelines() <CR>"
endfunction

"FUNCTION: ToggleMarkPipeline
"This function is used to indicate whether a pipeline should be run or not
"Marking a line with an M indicates that the pipeline should be run.
function! vimanzo#pipelines#ToggleMarkPipeline()
  let l:mark_char = getline('.')[0]
  if l:mark_char == " "
    silent execute ":normal 0rM" 
  else
    silent execute ":normal 0r "
  endif
  silent execute ":normal j"
endfunction

"FUNCTION: FilterBufferByString 
"This removes all lines not matching a prompted regex
"We should consider putting this in the utilities file 
function! vimanzo#pipelines#FilterBufferByString()
  let l:filter_string = input("Enter Regex to Filter By: ")
  execute ":v/" . l:filter_string . "/d"
endfunction 

"FUNCTION: RunSelectedPipelines
"This function is called when a user is done 
"selecting the pipelines they want to run. 
function! vimanzo#pipelines#RunSelectedPipelines()
  let l:pipelines = vimanzo#pipelines#GatherMarkedPipelines() 
  silent! execute "normal ggdGd$"
  for s:pipeline in l:pipelines
    for s:uri in keys(g:pipeline_uri_label_dictionary) "This is backwards but we're using internals for other things
      if g:pipeline_uri_label_dictionary[s:uri] == s:pipeline
     "   call writefile(s:pipeline, "Pipelines")
        call vimanzo#pipelines#RunPipeline(s:uri, s:pipeline)
      endif
    endfor
  endfor
endfunction

"FUNCTION: GatherMarkedPipelines
"This is a helper for RunSelectedPipelines 
function! vimanzo#pipelines#GatherMarkedPipelines()
  let l:last_line = line("$")
  let l:current_line = 1 
  let l:results = []
  while l:current_line <= l:last_line
    let l:line_text = getline(l:current_line)
    let l:mark_label_array = split(l:line_text)
    let l:mark = l:mark_label_array[0]
    if l:mark ==# "M"
      let l:label = join(l:mark_label_array[1:])
      call add(l:results, l:label)
    endif 
    let l:current_line += 1
  endwhile
return l:results
endfunction

"FUNCTION: RunPipeline
"This is the core function for running pipelines 
"Currently it's only intended use is as a help to 
"RunSelectedPipelines
function! vimanzo#pipelines#RunPipeline(pipeline_uri, pipeline_label)
  let l:jobs = vimanzo#pipelines#GetJobsForPipeline(a:pipeline_uri)
  let l:pipeline_filename = "run_pipeline_" . substitute(a:pipeline_label, " ", "_", "g") . ".trig"
  call vimanzo#pipelines#GeneratePipelinePayload(l:jobs, l:pipeline_filename)
  call vimanzo#pipelines#CallRunPipelineSemanticService(l:pipeline_filename)
"  call vimanzo#pipelines#MonitorJobs()
endfunction 
"FUNCTION: GetJobsForPipeline
"Currently we do not support running only selected jobs in a pipeline
"this function gathers all of them. 
function! vimanzo#pipelines#GetJobsForPipeline(pipeline_uri)
  let l:etl_prefix = "PREFIX etl:<http://cambridgesemantics.com/ontologies/ETL#> \n"
  let l:select = "SELECT ?job \n" 
  let l:type = "<" . a:pipeline_uri . "> a etl:DatasetProject . \n "
  let l:group =  "<" . a:pipeline_uri . "> etl:group ?group . \n" 
  let l:item  =  "?group etl:item ?job . \n"
  let l:where = "WHERE { " . l:type . l:group . l:item . " } " 
  let l:query = l:etl_prefix . l:select  . l:where 
  return vimanzo#query#queryForVimInternal(l:query, 0, "")
endfunction

"FUNCTION: GeneratePipelinePayload
"In order to run a semantic service we need to have a file 
"on disk with the payload. This function generates that payload
"One thing to note: This is dangerous if we have concurrent users:
"someone could use the a different ETL engine or have altered the 
"jobs that are in the pipeline I don't know what to do about this,
"so I'll just leave the warning notice.  
function! vimanzo#pipelines#GeneratePipelinePayload(job_results, pipeline_filename)
  let l:sdi_prefix = "@prefix sdi:<http://cambridgesemantics.com/ontologies/2015/08/SDIService#> ."
  let l:graph = "<http://cambridgesemantics.com/semanticServices/SDIService/runETLTransformation> { "
  let l:type  = "sdi:sdiRequest a sdi:SDIRequest ; " 
  let l:etl_engine = "    sdi:etlEngineConfig <" . g:etl_engine_uri . "> ; "
  let l:publish = "    sdi:includePrecedingStages \"true\"^^<http://www.w3.org/2001/XMLSchema#boolean> ; " 
  let l:jobs_rdf = "" 
  let l:payload = [l:sdi_prefix, l:graph, l:type, l:etl_engine, l:publish]
  let l:last_job_idx = len(a:job_results) - 1 
  let l:current_job_idx = 0 
  for s:job_result in a:job_results
    let l:job_context = "    sdi:jobContext [ " 
    call add(l:payload, l:job_context)
    let l:job_type =   "       a sdi:JobContext ; "
    call add(l:payload, l:job_type)
    let l:job_decl = "        sdi:job <" . s:job_result["job"] . "> ] "
    if l:current_job_idx == l:last_job_idx
      let l:job_decl = l:job_decl . " . "
    else 
      let l:job_decl = l:job_decl . " ; "
    endif 
    let l:current_job_idx += 1
    call add(l:payload, l:job_decl)
  endfor 
  call add(l:payload, " } ")
  call writefile(l:payload, a:pipeline_filename)
  return a:pipeline_filename
endfunction

"FUNCTION: CallRunPipelineSemanticService 
"This function calls the semantic service to run a pipeline. 
"This includes generating and compiling the scala code 
"that spark runs. 
function! vimanzo#pipelines#CallRunPipelineSemanticService(pipeline_filename)
  let l:sdi_prefix =  "http://cambridgesemantics.com/semanticServices/SDIService#"
  let l:service_uri = l:sdi_prefix . "runETLTransformation" 
  echom "! " . g:anzo_command . " call -z " . g:anzo_settings . " " . l:service_uri . " " . a:pipeline_filename 
  execute "! " . g:anzo_command . " call -z " . g:anzo_settings . " " . l:service_uri . " " . a:pipeline_filename
endfunction




