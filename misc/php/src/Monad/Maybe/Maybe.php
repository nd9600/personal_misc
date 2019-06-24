<?php
declare(strict_types=1);


namespace App\Monad\Maybe;


use App\Monad\Monad;

abstract class Maybe extends Monad
{
    static function return($data): Monad
    {
        return new Just($data);
    }
    
    /**
     * @param Maybe $maybe
     * @param callable $f
     * @return Maybe
     */
    static function bind(Monad $maybe, callable $f): Monad
    {
        $isJust = get_class($maybe) === Just::class;
        if ($isJust) {
            /** @var Just $maybe */
            return $f($maybe->getData());
        }
        return new Nothing();
    }
}