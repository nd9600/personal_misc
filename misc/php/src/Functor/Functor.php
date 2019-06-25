<?php
declare(strict_types=1);


namespace App\Functor;


/**
 * Functors
 * fmap  :: (Functor f)     =>   (a -> b) -> f a -> f b
 *
 * Functor laws
 * ID law
 *      fmap id === id
 *
 * Composing law
 *      fmap (f . g) F = fmap f (fmap g F)
 */

abstract class Functor {
    
    /**
     * fmap :: (a -> b) -> f a -> f b
     * fmap id        === id
     * fmap (f . g) F === fmap f (fmap g F)
     * @param callable $callable
     * @param Functor $functor
     * @return Functor
     */
    abstract static function fmap(callable  $callable, Functor $functor): Functor;
}