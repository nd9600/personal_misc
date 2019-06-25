<?php
declare(strict_types=1);


namespace Tests\Functor;

use App\Monad\Maybe\Just;
use App\Monad\Maybe\Maybe;
use App\Monad\Maybe\Nothing;
use App\Utils;
use PHPUnit\Framework\TestCase;
use Tests\LambdasAsMethods;

/**
 * Functors
 * fmap  :: (Functor f)     =>   (a -> b) -> f a -> f b
 *
 * Functor laws
 * ID law
 * fmap id        === id
 *
 * Composing law
 * fmap (f . g) F === fmap f (fmap g F)
 *
 */
class MaybeTest extends TestCase
{
    use LambdasAsMethods;
    
    /** @var callable */
    private $double;
    
    /** @var callable */
    private $add1;
    
    protected function setUp(): void
    {
        parent::setUp();
        $this->double = function (int $i): int {
            return $i * 2;
        };
        $this->add1 = function (int $i): int {
            return $i + 1;
        };
    }
    
    /**
     * fmap id === id
     */
    public function testIDLawWithJust()
    {
        $id = function ($x) {
            return $x;
        };
        $maybe = new Just(123);
        
        $this->assertEquals(
            $id($maybe),
            Maybe::fmap($id, $maybe)
        );
    }
    
    /**
     * fmap id === id
     */
    public function testIDLawWithNothing()
    {
        $id = function ($x) {
            return $x;
        };
        $maybe = new Nothing();
        
        $this->assertEquals(
            $id($maybe),
            Maybe::fmap($id, $maybe)
        );
    }
    
    /**
     * fmap (f . g) F === fmap f (fmap g F)
     */
    public function testComposingLawWithJust()
    {
        $maybe = new Just(123);
        
        $this->assertEquals(
            Maybe::fmap(
                Utils::compose($this->double, $this->add1),
                $maybe
            ),
            Maybe::fmap(
                $this->double,
                Maybe::fmap(
                    $this->add1,
                    $maybe
                )
            )
        );
    }
    
    /**
     * fmap (f . g) F === fmap f (fmap g F)
     */
    public function testComposingLawWithNothing()
    {
        $maybe = new Nothing();
        
        $this->assertEquals(
            Maybe::fmap(
                Utils::compose($this->double, $this->add1),
                $maybe
            ),
            Maybe::fmap(
                $this->double,
                Maybe::fmap(
                    $this->add1,
                    $maybe
                )
            )
        );
    }
    
}