
const fs = require("fs")

const kbn_pkgs = fs.readdirSync(__dirname+"/node_modules/@kbn",{withFileTypes:true})

for (var i in kbn_pkgs) {

    // Could be symlink
    // if (! (kbn_pkgs[i].isDirectory()) continue;

    const k = kbn_pkgs[i].name
    module.exports[k.replaceAll('-','_')] = () => {
        if (this['_'+k]) return this['_'+k]
        return this['_'+k] = require('@kbn/'+k)
    }
}
