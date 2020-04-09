# Welcome to vimanzo

This project brings functionality of Anzo to vim.
Expect nothing except collaboration so far, the idea is fairly experimental.

## Goals

Some possible areas of implementation/goals

* provide editor/CRUD for named graphs in the Anzo Journal
* report/navigation of Anzo configuration assets
* form or template-based editing of Anzo configuration assets
* Execution of Anzo devops
* query builder/runner/result browser

should bundle or rely on a good RDF filetype plugin


## Scenario - Data Layers

One part of the Anzo UI that is fairly well designed but could use a better client is the Data Layers UI.
In vim, this could be the start of a graphmart manager.  Basically you'd use VIM to interact with specific named graphs on the server.  We might want to prove out this general capability as an end-to-end start.

Story is that as a data integrator working on data layers, I want to 
  * edit query step's query, 
  * save it, 
  * refresh the graphmart.

* as in Anzo, the graphmart should belong to just one person so as to avoid concurrent editing issues.

* Operations

A. Navigation to data layer
   * List graphmarts
   * Select a graphmart/data layers
   * Select a query step (just list query steps?)
   * Open the query for the query step

   This functionality probably depends on just the ability to run a sparql query and display results, which is a general requirement of the plugin.
   The UI contains a list of graphmart names, maybe browsable like a tree (NERDTree?)

B. Edit query
   * A normal sparql edit buffer should be very good here.  Whether such a syntax exists is another question...
   * automated prefix resolution (PFE) - subfeature unto itself
   * 'query builder' functionality too?

C. Save query
   * Save in this case would have to update a triple in the query step named graph...

D. Refresh Graphmart
   * I envision an 'operations' view that will help someone quickly navigate common devops commands such as
     * run pipeline/job
     * reload graphmart
     * refresh graphmart


Usage
Mappings
Configuration
License
Bugs
Contributing
Changelog
Credits

