<?php
declare(strict_types=1);


namespace App\Monad\Maybe;


use App\Applicative\Applicative;
use App\Functor\Functor;
use App\Monad\Monad;

class Maybe extends Monad
{
    /*
     * ########################################
     *  Functor
     * ########################################
     */
    
    /**
     * fmap :: (a -> b) -> f a -> f b
     * fmap id        === id
     * fmap (f . g) F === fmap f (fmap g F)
     * @param callable $callable
     * @param Functor $maybe
     * @return Maybe
     */
    static function fmap(callable $callable, Functor $maybe): Functor
    {
        $isJust = get_class($maybe) === Just::class;
        /** @var Just $maybe */
        return $isJust
            ? new Just($callable($maybe->getData()))
            : $maybe;
    }
    
    /*
     *
     *
     *
     *
     *
     *
     * ########################################
     *  Applicative
     * ########################################
     */
    
    const pure = "App\Monad\Maybe\Maybe::pure";
    
    /**
     * pure :: a -> f a
     * @param $data
     * @return Applicative
     */
    static function pure($data): Applicative
    {
        return new Just($data);
    }
    
    /**
     * (<*>) :: f (a -> b) -> f a -> f b
     * @param Applicative $applicative
     * @param Applicative $secondApplicative
     * @return Applicative
     */
    static function apply(Applicative $applicative, Applicative $secondApplicative): Applicative
    {
        $isJust = get_class($applicative) === Just::class;
        return $isJust
            ? static::fmap($applicative->getData(), $secondApplicative)
            : $applicative;
    }
    
    /*
     *
     *
     *
     *
     *
     *
     * ########################################
     *  Monad
     * ########################################
     */
    
    const return = "App\Monad\Maybe\Maybe::return";
    
    /**
     * @param $data
     * @return Maybe
     */
    static function return($data): Monad
    {
        /** @var Monad $monad */
        $monad = static::pure($data);
        return $monad;
    }
    
    /**
     * instance  Monad Maybe  where
     *      (Just x) >>= k      = k x
     *      Nothing  >>= _      = Nothing
     *
     *      return              = Just
     * @param Maybe $either
     * @param callable $f
     * @return Maybe
     */
    static function bind(Monad $maybe, callable $f): Monad
    {
        $isJust = get_class($maybe) === Just::class;
        return $isJust
            ? $f($maybe->getData())
            : $maybe;
    }
    
    /*
     *
     *
     *
     *
     *
     * ########################################
     *  helper functions
     * ########################################
     */
    
    /**
     * Returns Just($data), or Nothing if $data is null
     * @param mixed $data
     * @return Maybe
     */
    static function fromNullable($data): Maybe
    {
        return is_null($data)
            ? new Nothing()
            : new Just($data);
    }
    
    /**
     * Returns Just($else) if $this is Nothing, or $this if it's a Just
     * @param mixed $else
     * @return Just
     */
    public function getOrElse($else): Just
    {
        $isJust = get_class($this) === Just::class;
        return $isJust
            ? $this
            : new Just($else);
    }
    
    /**
     * Returns Just($else) if $this is Nothing, or $justFunction($this) if it's a Just
     * @param mixed $nothingDefault
     * @param callable $justFunction
     * @return Just
     */
    public function fold($nothingDefault, callable $justFunction): Just
    {
        $isJust = get_class($this) === Just::class;
        return $isJust
            ? $justFunction($this->getData())
            : new Just($nothingDefault);
    }
}