<?php
declare(strict_types=1);

namespace App;

/**
 * A composable way to build algorithmic transformations, which can be parallelised and done lazily, and the operations aren't tied to the input or output data structures
 */
class Transducers
{
    public static function map(callable $elementTransformer): callable
    {
        $transducer = function(callable $combiner) use ($elementTransformer) {
            $reducingFunction = function($accum, $input) use ($elementTransformer, $combiner) {
                return $combiner($accum, $elementTransformer($input));
            };
            return $reducingFunction;
        };
        return $transducer;
    }
    
    public static function filter(callable $predicate): callable
    {
        $transducer = function(callable $combiner) use ($predicate) {
            $reducingFunction = function($accum, $input) use ($predicate, $combiner) {
                return $predicate($input)
                    ? $combiner($accum, $input)
                    : $accum;
            };
            return $reducingFunction;
        };
        return $transducer;
    }
}