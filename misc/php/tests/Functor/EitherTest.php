<?php
declare(strict_types=1);


namespace Tests\Functor;

use App\Monad\Either\Either;
use App\Monad\Either\Left;
use App\Monad\Either\Right;
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
class EitherTest extends TestCase
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
    public function testIDLawWithRight()
    {
        $id = function ($x) {
            return $x;
        };
        $either = new Right(123);
        
        $this->assertEquals(
            $id($either),
            Either::fmap($id, $either)
        );
    }
    
    /**
     * fmap id === id
     */
    public function testIDLawWithLeft()
    {
        $id = function ($x) {
            return $x;
        };
        $either = new Left(456);
        
        $this->assertEquals(
            $id($either),
            Either::fmap($id, $either)
        );
    }
    
    /**
     * fmap (f . g) F === fmap f (fmap g F)
     */
    public function testComposingLawWithRight()
    {
        $either = new Right(123);
        
        $this->assertEquals(
            Either::fmap(
                Utils::compose($this->double, $this->add1),
                $either
            ),
            Either::fmap(
                $this->double,
                Either::fmap(
                    $this->add1,
                    $either
                )
            )
        );
    }
    
    /**
     * fmap (f . g) F === fmap f (fmap g F)
     */
    public function testComposingLawWithLeft()
    {
        $either = new Left(456);
        
        $this->assertEquals(
            Either::fmap(
                Utils::compose($this->double, $this->add1),
                $either
            ),
            Either::fmap(
                $this->double,
                Either::fmap(
                    $this->add1,
                    $either
                )
            )
        );
    }
    
}