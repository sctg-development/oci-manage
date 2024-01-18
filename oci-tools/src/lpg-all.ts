import { getAllOtherTenancies } from "./oci.js";
import db from "./config/oci.json" assert {type: "json"}
import { link2VCN } from "./lpg.js";

const args = process.argv.slice(2);
if (args.length == 1 && typeof args[0] == "string") {
    const me = args[0];
    console.log(`Building a LPG for ${me} `);
    const others = getAllOtherTenancies(db, me);
    others.forEach(async other => {
        await link2VCN(me, other.tenancy);
    })
} else {
    console.log("create all lpg for this new tenancy")
    console.log("node --loader ts-node/esm lpg-all.ts  newtenancy ")
}