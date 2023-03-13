
const _ = require("lodash")
const KP = require(".")

var eq = KP.es_query()

var dsl = eq.buildEsQuery(null, {language:"kuery", query:"field1:* AND field2:value"})

if (
    _.isEqual(dsl, {"bool":{"must":[],"filter":[{"bool":{"filter":[{"bool":{"should":[{"exists":{"field":"field1"}}],"minimum_should_match":1}},{"bool":{"should":[{"match":{"field2":"value"}}],"minimum_should_match":1}}]}}],"should":[],"must_not":[]}})
)
    console.log("Success!")
else
    console.log("Failure!")

/*
 * I wanted to use Jest, but I could not get Jest to keep its nose out of ./kibana or the node_modules/@kbn's .ts
 * source files. Not interested in testing kibana, just want to know if I can load the selected module and use it.
 */

