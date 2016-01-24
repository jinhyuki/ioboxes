<?php

namespace AppBundle\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Security;
use AppBundle\Entity\CheckSheet;
use AppBundle\Entity\Error;
use AppBundle\Form\CheckSheetType;
use AppBundle\Entity\Product;

class DefaultController extends Controller
{
    /**
     * @Route("/", name="homepage")
     */
    public function indexAction(Request $request)
    {
        // replace this example code with whatever you need
        return $this->render('default/index.html.twig', [
            'base_dir' => realpath($this->container->getParameter('kernel.root_dir').'/..'),
        ]);
    }

    /**
     * @Route("/", name="json")
     */
    public function jsonAction()
    {

        $em = $this->getDoctrine()->getManager();

        $checkSheets = $em->getRepository('AppBundle:CheckSheet')->findBy( 
            array(),
            array('id' => 'ASC')
        );
        $result = array('result' => $checkSheets, 'errors' => array());
        $json = $this->get('jms_serializer')->serialize($result, 'json');

        //dump($checkSheets, $json);

        return new Response(
            $json,
            Response::HTTP_OK,
            array('Content-Type' => 'application/json')
        );
    }


    /**
     * @Route("/default/create", name="default_create")
     */
    public function createAction()
    {
        $product = new Product();
        $product->setName('A Foo Bar');
        $product->setPrice('19.99');
        $product->setDescription('Lorem ipsum dolor');

        $em = $this->getDoctrine()->getManager();

        $em->persist($product);
        $em->flush();

        return new Response('Created product id '.$product->getId());
    }

    /**
     * @Route("/admin", name="admin_page")
     * @Security("has_role('ROLE_ADMIN')")
     */
    public function adminAction()
    {
        return new Response('<html><body>Admin page!</body></html>');
    }

    /**
     * @Route("/account", name="user_account")
     * @Security("has_role('ROLE_USER')")
     */
    public function accountAction()
    {
        return new Response('<html><body>Account page!</body></html>');
    }
}
