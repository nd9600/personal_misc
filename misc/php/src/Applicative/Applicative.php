<?php
declare(strict_types=1);


namespace App\Applicative;


use App\Functor\Functor;

/**
 * Applicatives
 * class (Functor f) => Applicative f where
 *      pure :: a -> f a
 *      (<*>) :: f (a -> b) -> f a -> f b         (called apply)
 *
 * Applicative laws
 * Fmap law
 *      pure f <*> x = fmap f x
 *
 * Identity
 *      pure id <*> v = v
 *
 * Homomorphism
 *      pure f <*> pure x = pure (f x)
 *
 * Interchange
 *      u <*> pure y = pure ($ y) <*> u
 *
 * Composition
 *      pure (.) <*> u <*> v <*> w = u <*> (v <*> w)
 *
 * @package App\Applicative
 */

abstract class Applicative extends Functor
{
    /**
     * pure :: a -> f a
     * @param $data
     * @return Applicative
     */
    abstract static function pure($data): Applicative;
    
    
    /**
     * (<*>) :: f (a -> b) -> f a -> f b
     * @param Applicative $applicative with function inside
     * @param Applicative $secondApplicative with data inside
     * @return Applicative
     */
    abstract static function apply(Applicative $applicative, Applicative $secondApplicative): Applicative;
}