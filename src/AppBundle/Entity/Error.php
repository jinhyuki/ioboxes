<?php

namespace AppBundle\Entity;

use JMS\Serializer\Annotation\ExclusionPolicy;
use JMS\Serializer\Annotation\Expose;


/**
 * Error
 * @ExclusionPolicy("all")
 */
class Error
{
    /**
     * Error code
     * @Expose
     */
    protected $code;

    /**
     * Error message
     * @Expose
     */
    protected $message;    

    public function __construct($code=null, $message=null) {
        $this->code = $code;
        $this->message = $message;
    }

    /**
     * Set code
     *
     * @param string $code
     *
     * @return Error
     */
    public function setCode($code)
    {
        $this->code = $code;

        return $this;
    }

    /**
     * Get code
     *
     * @return string
     */
    public function getCode()
    {
        return $this->code;
    }

    /**
     * Set message
     *
     * @param string $message
     *
     * @return Error
     */
    public function setMessage($message)
    {
        $this->message = $message;

        return $this;
    }

    /**
     * Get message
     *
     * @return string
     */
    public function getMessage()
    {
        return $this->message;
    }
}
