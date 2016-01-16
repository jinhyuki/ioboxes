<?php

namespace AppBundle\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use AppBundle\Entity\CheckSheet;
use AppBundle\Form\CheckSheetType;

/**
 * CheckSheet controller.
 *
 * @Route("/checksheet")
 */
class CheckSheetController extends Controller
{
    /**
     * Lists all CheckSheet entities.
     *
     * @Route("/", name="checksheet_index")
     * @Method("GET")
     */
    public function indexAction()
    {
        $em = $this->getDoctrine()->getManager();

        $checkSheets = $em->getRepository('AppBundle:CheckSheet')->findAll();

        return $this->render('checksheet/index.html.twig', array(
            'checkSheets' => $checkSheets,
        ));
    }

    /**
     * Creates a new CheckSheet entity.
     *
     * @Route("/new", name="checksheet_new")
     * @Method({"GET", "POST"})
     */
    public function newAction(Request $request)
    {
        $checkSheet = new CheckSheet();
        $form = $this->createForm('AppBundle\Form\CheckSheetType', $checkSheet);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $em = $this->getDoctrine()->getManager();
            $em->persist($checkSheet);
            $em->flush();

            return $this->redirectToRoute('checksheet_show', array('id' => $checksheet->getId()));
        }

        return $this->render('checksheet/new.html.twig', array(
            'checkSheet' => $checkSheet,
            'form' => $form->createView(),
        ));
    }

    /**
     * Finds and displays a CheckSheet entity.
     *
     * @Route("/{id}", name="checksheet_show")
     * @Method("GET")
     */
    public function showAction(CheckSheet $checkSheet)
    {
        $deleteForm = $this->createDeleteForm($checkSheet);

        return $this->render('checksheet/show.html.twig', array(
            'checkSheet' => $checkSheet,
            'delete_form' => $deleteForm->createView(),
        ));
    }

    /**
     * Displays a form to edit an existing CheckSheet entity.
     *
     * @Route("/{id}/edit", name="checksheet_edit")
     * @Method({"GET", "POST"})
     */
    public function editAction(Request $request, CheckSheet $checkSheet)
    {
        $deleteForm = $this->createDeleteForm($checkSheet);
        $editForm = $this->createForm('AppBundle\Form\CheckSheetType', $checkSheet);
        $editForm->handleRequest($request);

        if ($editForm->isSubmitted() && $editForm->isValid()) {
            $em = $this->getDoctrine()->getManager();
            $em->persist($checkSheet);
            $em->flush();

            return $this->redirectToRoute('checksheet_edit', array('id' => $checkSheet->getId()));
        }

        return $this->render('checksheet/edit.html.twig', array(
            'checkSheet' => $checkSheet,
            'edit_form' => $editForm->createView(),
            'delete_form' => $deleteForm->createView(),
        ));
    }

    /**
     * Deletes a CheckSheet entity.
     *
     * @Route("/{id}", name="checksheet_delete")
     * @Method("DELETE")
     */
    public function deleteAction(Request $request, CheckSheet $checkSheet)
    {
        $form = $this->createDeleteForm($checkSheet);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $em = $this->getDoctrine()->getManager();
            $em->remove($checkSheet);
            $em->flush();
        }

        return $this->redirectToRoute('checksheet_index');
    }

    /**
     * Creates a form to delete a CheckSheet entity.
     *
     * @param CheckSheet $checkSheet The CheckSheet entity
     *
     * @return \Symfony\Component\Form\Form The form
     */
    private function createDeleteForm(CheckSheet $checkSheet)
    {
        return $this->createFormBuilder()
            ->setAction($this->generateUrl('checksheet_delete', array('id' => $checkSheet->getId())))
            ->setMethod('DELETE')
            ->getForm()
        ;
    }
}
