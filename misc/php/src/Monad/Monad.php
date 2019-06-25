<?php
declare(strict_types=1);


namespace App\Monad;

use App\Applicative\Applicative;

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
 *
 *
 *
 * Applicatives
 * class (Functor f) => Applicative f where
 *      pure :: a -> f a
 *      (<*>) :: f (a -> b) -> f a -> f b         (called apply)
 *
 * Applicative laws
 * Fmap law
 *      pure f <*> x = fmap f x
 *
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
 *
 *
 * Monads
 * return :: a -> m a
 * (>>=)  :: (Monad m)       => m a -> (a -> m b) -> m b
 *
 * Monad laws
 * Left identity
 *      f :: (a -> m b),
 *      return x >>= f    === f x
 *
 * Right identity
 *      m >>= return      === m
 *
 * Associativity
 *      f :: (a -> m b),
 *      g :: (c -> m d),
 *      (m >>= f) >>= g   === m >>= (\x -> f x >>= g)
 *
 * @package App\Monad
 */
abstract class Monad extends Applicative
{
    /**
     * return :: a -> m a
     * @param $data
     * @return Monad
     */
    abstract static function return($data): Monad;
    
    /**
     * (>>=) :: (Monad m)       => m a -> (a -> m b) -> m b
     * @param Monad $m
     * @param callable $f
     * @return Monad
     */
    abstract static function bind(Monad $m, callable $f): Monad;
    
    /*
     * ########################################
     *  helper functions
     * ########################################
     */
    
    public function bindClass(callable $f): Monad
    {
        return static::bind($this, $f);
    }
    
    /**
     * Allows you to do
     * ```
     * Monad::composeWithBinds(
     *      $monad,
     *      $f, $g
     * );
     * instead of
     * Monad::bind(
     *      Monad::bind($monad, $f),
     *      $g
     * );
     * ```
     * @param Monad $monad
     * @param mixed ...$functions
     * @return Monad
     */
    static function composeWithBinds(Monad $monad, ...$functions): Monad
    {
        $result = $monad;
        foreach ($functions as $function) {
            $result = static::bind($result, $function);
        }
        return $result;
    }
}