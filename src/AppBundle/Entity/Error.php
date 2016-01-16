<?php

namespace AppBundle\Entity;


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

    function __construct($code=null, $message=null) {
        // parent constructor called first ALWAYS
        parent::__construct();

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
