const trace = (msg) => {
    return (value) => {
        console.log(msg, value);
        return value;
    }
}

const compose = (...fns) => x => fns.reduceRight((v, f) => f(v), x);

const appendNode = (nodeContent) => {
    const p = document.createElement("p");
    p.innerText = JSON.stringify(nodeContent);
    document.querySelector("#app").append(p);
}

// ########################################

/**
 * Concats `b` onto `a`
 * @param Array a 
 * @param any b 
 */
function concat(a, b) {
    return a.concat(b);
}

// ########################################
const app = document.getElementById("app");

let a = [1, 2, 3, 4];

// ########################################
// map

const inc = (input) => {
    return input + 1;
};
// a.map(inc)
// .forEach(element => {
//     appendNode(
//         trace("map, element")(element)
//     )
// });

// reduce

const incReduce = (accum, input) => {
    return concat(accum, input + 1);
};
// a.reduce(incReduce, [])
// .forEach(element => {
//     appendNode(
//         trace("reduce, element")(element)
//     )
// });

// use reduce to map

const mapWithIncReduce = (array) => {
    return array.reduce(incReduce, []);
};
// mapWithIncReduce(a)
// .forEach(element => {
//     appendNode(
//         trace("mapWithIncReduce, element")(element)
//     )
// });

// abstract map with reduce

const map = (elementTransformer, array) => {
    const reducingFunction = (accum, input) => {
        return concat(accum, elementTransformer(input));
    };
    return array.reduce(reducingFunction, []);
};
// map(inc, a)
// .forEach(element => {
//     appendNode(
//         trace("abstracted map with reduce, element")(element)
//     )
// });

// ########################################
// filter

const gt2 = (element) => {
    return element > 2;
}
// a.filter(gt2)
// .forEach(element => {
//     appendNode(
//         trace("filter, element")(element)
//     )
// });

// reduce

const gt2Reduce = (accum, input) => {
    return input > 2
        ? concat(accum, input)
        : accum;
}
// a.reduce(gt2Reduce, [])
// .forEach(element => {
//     appendNode(
//         trace("reduce, element")(element)
//     )
// });

// use reduce to filter

const filter = (predicate, array) => {
    const reducingFunction = (accum, input) => {
        return predicate(input)
            ? concat(accum, input)
            : accum;
    };
    return array.reduce(reducingFunction, []);
}

filter(
    compose(gt2, trace("filtering ele")), 
    map(
        compose(inc, trace("mapping ele")),
        a
    )
)
.forEach(element => {
    appendNode(
        trace("abstracted filter with reduce, element")(element)
    )
});