<?php

namespace AppBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * CheckItem
 *
 * @ORM\Table(name="check_item")
 * @ORM\Entity(repositoryClass="AppBundle\Repository\CheckItemRepository")
 */
class CheckItem
{
    /**
     * @var int
     *
     * @ORM\Column(name="id", type="integer")
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    private $id;

    /**
     * @var string
     *
     * @ORM\Column(name="text", type="string", length=512)
     */
    private $text;

    /**
     * @var int
     *
     * @ORM\Column(name="reward", type="integer")
     */
    private $reward;

    /**
     * @var boolean
     *
     * @ORM\Column(name="done", type="boolean")
     */
    private $done;

    /**
     * @var string
     *
     * @ORM\Column(name="status", type="string", length=1)
     */
    private $shown;

    /**
     * Get id
     *
     * @return int
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Set text
     *
     * @param string $text
     *
     * @return CheckItem
     */
    public function setText($text)
    {
        $this->text = $text;

        return $this;
    }

    /**
     * Get text
     *
     * @return string
     */
    public function getText()
    {
        return $this->text;
    }

    /**
     * Set reward
     *
     * @param integer $reward
     *
     * @return CheckItem
     */
    public function setReward($reward)
    {
        $this->reward = $reward;

        return $this;
    }

    /**
     * Get reward
     *
     * @return int
     */
    public function getReward()
    {
        return $this->reward;
    }

    /**
     * Set status
     *
     * @param string $status
     *
     * @return CheckItem
     */
    public function setStatus($status)
    {
        $this->status = $status;

        return $this;
    }

    /**
     * Get status
     *
     * @return string
     */
    public function getStatus()
    {
        return $this->status;
    }
}

