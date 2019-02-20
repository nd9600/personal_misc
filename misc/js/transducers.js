// https://tgvashworth.com/2014/08/31/csp-and-transducers.html#transducers-in-js

const trace = (msg) => {
    return (value) => {
        console.log(msg + ":", value);
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
    return element < 2;
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

// performs the first transformation on the whole collection before moving on to the second
// filter(
//     compose(gt2, trace("1 filtering ele")), 
//     map(
//         compose(inc, trace(" 1mapping ele")),
//         a
//     )
// )
// .forEach(element => {
//     appendNode(
//         trace("abstracted filter with reduce, element")(element)
//     )
// });

// ########################################
// we want it to perform all the transformations on the first element of the collection before moving on to the second,
// since the other way can't be parallelised, isn't lazy, and only works for arrays

// we need to pull out the array.reduce(), the initial value [], and the concat(accum, input)

const mapper = (elementTransformer) => {
    const reducingFunction = (accum, input) => {
        return concat(accum, elementTransformer(input));
    };
    return reducingFunction;
};
const filterer = (predicate) => {
    const reducingFunction = (accum, input) => {
        return predicate(input)
            ? concat(accum, input)
            : accum;
    };
    return reducingFunction;
}

// a.reduce(mapper(inc), [])
// .forEach(element => {
//     appendNode(
//         trace("mapper, element")(element)
//     )
// });
// a.reduce(filterer(gt2), [])
// .forEach(element => {
//     appendNode(
//         trace("filterer, element")(element)
//     )
// });

// reducing functions have the form (a, b) -> a
// like concat, which is (a, b) => a.concat(b)
// and ALSO like the reducing function inside mapper and filterer

const id = x => x;
// a.reduce(mapper(id), [])
// .forEach(element => {
//     appendNode(
//         trace("id, element")(element)
//     )
// });

const filtererDefinedWithMapper = (predicate) => {
    // mapper(id) is just (accum, input) => {
    //     return concat(accum, id(input));
    // };

    const reducingFunction = (accum, input) => {
        return predicate(input)
            ? mapper(id)(accum, input)
            : accum;
    };
    return reducingFunction;
};
// a.reduce(filtererDefinedWithMapper(gt2), [])
// .forEach(element => {
//     appendNode(
//         trace("filtererDefinedWithMapper, element")(element)
//     )
// });

// pulling out concat

const mapping = (elementTransformer) => {
    const transducer = (combiner) => {
        const reducingFunction = (accum, input) => {
            return combiner(accum, elementTransformer(input));
        };
        return reducingFunction;
    };
    return transducer;
};
const filtering = (predicate) => {
    const transducer = (combiner) => {
        const reducingFunction = (accum, input) => {
            return predicate(input)
                ? combiner(accum, input)
                : accum;
        };
        return reducingFunction;
    }
    return transducer;
}

const transducedFilterAndMap = compose(
    filtering(
        gt2
    ),
    mapping(
        compose(inc, trace("2 mappingTransducer ele"))
    )
);
// a.reduce(
//     transducedFilterAndMap(concat), 
//     []
// )
// .forEach(element => {
//     appendNode(
//         trace("transducedFilterAndMap, element")(element)
//     )
// });

// ########################################

const transducedFilterAndMapNoLog = compose(
    filtering(gt2),
    mapping(inc)
);

a = [...Array(10e3).keys()];

console.time("transducer");

a.reduce(
    transducedFilterAndMapNoLog(concat), 
    []
)
console.timeEnd("transducer");





console.time("no transducer");

const filterAndMapNoLog = compose(
    filterer(gt2),
    mapper(inc)
);

a.reduce(
    filterAndMapNoLog, 
    []
)
console.timeEnd("no transducer");