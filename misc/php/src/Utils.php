<?php
declare(strict_types=1);

namespace App;

class Utils
{
    /**
     * Return a new function that composes all functions (right to left) in $functions into a single callable
     *
     * @param callable ...$functions
     * @return callable
     */
    public static function compose(...$functions): callable
    {
        return array_reduce(
            ($functions),
            function ($carry, $item) {
                return function($x) use ($carry, $item) {
                    return $item($carry($x));
                };
            },
            function ($f) {
                return $f;
            }
        );
    }
    
    /**
     * Concats $item onto $array
     * @param array $array
     * @param $item
     * @return array
     */
    public static function concat(array $array, $item): array
    {
        array_push($array, $item);
        return $array;
    }
    
    public static function arrayTransduce(callable $transducer, array $array, array $initial = []): array
    {
        $concat = function (array $a, $item): array {
            array_push($a, $item);
            return $a;
        };
        return array_reduce($array,
            $transducer($concat),
            $initial
        );
    }
    
    /**
     * Returns the $result of calling a function, and the $timeTaken for it to execute, in milliseconds.
     *
     * Use like this:
     *
     *     $a = 6;
     *     [$result, $timeTaken] = UtilityFunctions::timeFunction(function () use ($a) {
     *         return $a * 2;
     *     });
     *     Log::debug($timeTaken);
     *
     * @param callable $function
     *
     * @return array
     */
    public static function timeFunction(callable $function)
    {
        $start = microtime(true);
        
        $result = $function();
        
        $end = microtime(true);
        
        $timeTaken = round($end - $start, 3) * 1000;
        
        return [$result, $timeTaken];
    }
    
    /**
     * Returns the $result of calling a function, and logs the $timeTaken for it to execute, in milliseconds
     *
     * @param callable $function
     *
     * @param string $functionName
     *
     * @return mixed
     */
    public static function timeAndLogFunction(callable $function, string $functionName = "f")
    {
        [$result, $timeTaken] = static::timeFunction($function);
        echo "timeTaken, {$functionName}: {$timeTaken} ms\n";
        return $result;
    }
}