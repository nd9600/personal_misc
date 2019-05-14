<?php
/**
 * a composable way to build algorithmic transformations
 */

/**
 * @param $value
 * @param string $msg
 */
function echom($value, string $msg = "") {
    if ($msg !== "") {
        echo "$msg: ";
    }
    echo json_encode($value);
    echo "\n";
}

/**
 * Return a new function that composes all functions in $functions into a single callable
 *
 * @param callable ...$functions
 * @return callable
 * @todo Add callable typehint when HHVM supports use of typehints with variadic arguments
 * @see https://github.com/facebook/hhvm/issues/6954
 */
function compose(...$functions): callable
{
    return \array_reduce(
        $functions,
        function ($carry, $item) {
            return function ($x) use ($carry, $item) {
                return $item($carry($x));
            };
        },
        function ($value) {
            return $value;
        }
    );
}

function concat(array $array, $item) {
    array_push($array, $item);
    return $array;
}

$concat = function(array $array, $item) {
    array_push($array, $item);
    return $array;
};

echom(1234);

echom(
(compose(
    function($value) {
        return $value * 2;
    },
    function($value) {
        return $value * 2;
    })
)(1234)
);

$a = [1, 2, 3, 4];

echom(
    array_reduce($a, function ($acc, $input) {
            return concat($acc, $input + 1);
        },
        []
    ), "reduce"
);

function mapWithIncr($collection) {
    return array_reduce($collection,
        function ($result, $input) {
            return concat($result, $input + 1);
        },
        []
    );
}

echom(mapWithIncr($a), "mapWithIncr");

$inc = function($x) {
    return $x + 1;
};

function map($transform, $collection) {
    return array_reduce(
        $collection,
        function ($result, $input) use ($transform) {
            return concat($result, $transform($input));
        },
        []
    );
}

echom(map($inc, $a), "map(inc, a)");

$gt2 = function($x) {
    return $x > 2;
};

function filter($predicate, $array): array {
    $reducingFunction = function($accum, $input) use ($predicate) {
        return $predicate($input)
            ? concat($accum, $input)
            : $accum;
    };
    return array_reduce($array, $reducingFunction, []);
}

echom(filter($gt2, $a), "filter(gt2, a)");

function mapper($elementTransformer): callable {
    $reducingFunction = function($accum, $input) use ($elementTransformer) {
        return concat($accum, $elementTransformer($input));
    };
    return $reducingFunction;
};
function filterer($predicate): callable {
    $reducingFunction = function($accum, $input) use ($predicate) {
        return $predicate($input)
            ? concat($accum, $input)
            : $accum;
    };
    return $reducingFunction;
}

function mapping($elementTransformer) {
    $transducer = function($combiner) use ($elementTransformer) {
        $reducingFunction = function($accum, $input) use ($elementTransformer, $combiner) {
            return $combiner($accum, $elementTransformer($input));
        };
        return $reducingFunction;
    };
    return $transducer;
};
function filtering($predicate) {
    $transducer = function($combiner) use ($predicate) {
        $reducingFunction = function($accum, $input) use ($predicate, $combiner) {
            return $predicate($input)
                ? $combiner($accum, $input)
                : $accum;
        };
        return $reducingFunction;
    };
    return $transducer;
}

$transducedFilterAndMap = (compose(
    filtering($gt2),
    mapping($inc)
));

echom("transducer");

echom(
    array_reduce($a, $transducedFilterAndMap($concat), []),
    "transducedFilterAndMap"
);

echom("transducer");


exit;