<?php
declare(strict_types=1);


namespace App\Monad;

/**
 * Class Monad
 *
 * Functors
 * fmap  :: (Functor f)     =>   (a -> b) -> f a -> f b
 *
 *
 *
 * Applicatives
 * (<*>) :: (Applicative f) => f (a -> b) -> f a -> f b
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
abstract class Monad
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