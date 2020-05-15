function! vimanzo#internal#AppendAnzograph()
    let l:report = []
    let l:azg = vimanzo#query#internalQuery("azg.rq")
    for item in l:azg
        call add(l:report, item["azg_title"] . "\t <" . item["azg_uri"] . ">")
    endfor
    return l:report
endfunction


function! vimanzo#internal#AppendGraphmarts()
    let l:report = []
    let l:graphmarts = vimanzo#query#internalQuery("graphmarts.rq")
    let l:last_gm = ""
    let l:last_layer = ""
    for item in l:graphmarts
        let l:gm_uri = item["gm_uri"]
        let l:layer_uri = item["layer_uri"]
        let l:step_uri = item["step_uri"]
        if (l:gm_uri != l:last_gm)
            call add(l:report, "Graphmart: " . item["gm_title"] . "\t <" . l:gm_uri . ">")
        endif
        if (l:layer_uri != l:last_layer)
            call add(l:report, "  * Layer: " . item["layer_title"] . "\t <" . l:layer_uri . ">")
        endif
        call add(l:report, "    * Step: " . item["step_title"] . "\t <" . l:step_uri . ">")
        let l:last_gm = l:gm_uri
        let l:last_layer = l:layer_uri
    endfor
    return l:report
endfunction

function! vimanzo#internal#AppendPipelines()
    let l:report = []
    let l:pipelines = vimanzo#query#internalQuery("pipelines.rq")
    let l:last_project = ""
    let l:last_job = ""
    for item in l:pipelines
        let l:etl_uri = item["etl_uri"]
        let l:project_uri = item["project_uri"]
        let l:job_uri = item["job_uri"]
        if (l:project_uri != l:last_project)
            call add(l:report, "Pipeline: " . item["project_name"] . "\t <" . l:project_uri . ">")
        endif
        if (l:job_uri != l:last_job)
            call add(l:report, "  * Job: " . item["job_name"] . "\t <" . l:job_uri . ">")
        endif
        call add(l:report, "    * Run: " . item["status"] . "\t" . item["start_time"] . "\t" . item["end_time"])
        let l:last_project = l:project_uri
        let l:last_job = l:job_uri
    endfor
    return l:report
endfunction

function! vimanzo#internal#AppendModels()
    let l:report = []
    let l:models = vimanzo#query#internalQuery("models.rq")
    let l:last_model = ""
    let l:last_class = ""
    let l:last_prop = ""
    for item in l:models
        let l:model_uri = item["model_uri"]
        let l:class_uri = item["class_uri"]
        let l:prop_uri = item["prop_uri"]
        if (l:model_uri != l:last_model)
            call add(l:report, "Model: " . item["model_title"] . "\t <" . l:model_uri . ">")
        endif
        if (l:class_uri != l:last_class)
            call add(l:report, "  * Class: " . item["class_title"] . "\t <" . l:class_uri . ">")
        endif
        call add(l:report, "    * Property: " . item["prop_title"] . "(" . item["prop_range"] . ")\t <" . l:prop_uri . ">")
        let l:last_model = l:model_uri
        let l:last_class = l:class_uri
    endfor
    return l:report
endfunction

