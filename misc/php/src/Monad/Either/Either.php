<?php
declare(strict_types=1);


namespace App\Monad\Either;


use App\Monad\Monad;
use Exception;

abstract class Either extends Monad
{
    const return = "App\Monad\Either\Either::return";
    
    /**
     * @param $data
     * @return Right
     */
    static function return($data): Monad
    {
        return new Right($data);
    }
    
    /**
     * instance Monad (Either e) where
     *      return        = Right
     *      Right m >>= k = k m
     *      Left e  >>= _ = Left e
     * @param Either $either
     * @param callable $f
     * @return Either
     */
    static function bind(Monad $either, callable $f): Monad
    {
        $isRight = get_class($either) === Right::class;
        if ($isRight) {
            /** @var Right $either */
            return $f($either->getData());
        }
        /** @var Left $either */
        return $either;
    }
    
    /*
     * ########################################
     *  helper functions
     * ########################################
     */
    
    abstract function getData();
    
    /**
     * Returns $this if $this is a Left, or $rightFunction($this) if $this is a Right
     * @param callable $rightFunction
     * @return Either
     */
    public function map(callable $rightFunction): Monad
    {
        return $this->bindClass($rightFunction);
    }
    
    /**
     * Returns $leftFunction($this) if $this is a Left, or $rightFunction($this) if $this is a Right
     * @param callable $leftFunction
     * @param callable $rightFunction
     * @return Either
     */
    public function fold(callable $leftFunction, callable $rightFunction): Either
    {
        $isRight = get_class($this) === Right::class;
        return $isRight
            ? $rightFunction($this->getData())
            : $leftFunction($this->getData());
    }
    
    /**
     * Constructs an Either from a function that might throw
     * Returns Right($functionThatMightThrow()), or, if that throws an exception, catches it, and returns Left($onErrorFunction($exception));
     * @param callable $functionThatMightThrow
     * @param callable $onErrorFunction
     * @return Either
     */
    public static function tryCatch(callable $functionThatMightThrow, callable $onErrorFunction): Either
    {
        try {
            return new Right($functionThatMightThrow());
        } catch (Exception $exception) {
            return new Left($onErrorFunction($exception));
        }
    }
}