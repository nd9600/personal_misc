<?php
declare(strict_types=1);


namespace App\Monad\Maybe;


use App\Monad\Monad;

abstract class Maybe extends Monad
{
    const return = "App\Monad\Maybe\Maybe::return";
    
    /**
     * @param $data
     * @return Maybe
     */
    static function return($data): Monad
    {
        return new Just($data);
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
            : new Nothing();
    }
    
    /*
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