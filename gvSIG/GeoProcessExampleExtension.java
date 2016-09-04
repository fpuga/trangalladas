/**
 * This is free and unencumbered software released into the public domain.
 *
 * Anyone is free to copy, modify, publish, use, compile, sell, or
 * distribute this software, either in source code form or as a compiled
 * binary, for any purpose, commercial or non-commercial, and by any
 * means.
 *
 * In jurisdictions that recognize copyright laws, the author or authors
 * of this software dedicate any and all copyright interest in the
 * software to the public domain. We make this dedication for the benefit
 * of the public at large and to the detriment of our heirs and
 * successors. We intend this dedication to be an overt act of
 * relinquishment in perpetuity of all present and future rights to this
 * software under copyright law.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * For more information, please refer to <http://unlicense.org/>
 */

import java.util.HashMap;

import org.gvsig.andami.PluginServices;
import org.gvsig.andami.plugins.Extension;
import org.gvsig.andami.ui.mdiManager.IWindow;
import org.gvsig.app.project.documents.view.gui.IView;
import org.gvsig.fmap.mapcontext.layers.FLayers;
import org.gvsig.fmap.mapcontext.layers.vectorial.FLyrVect;
import org.gvsig.geoprocess.algorithm.intersection.IntersectionAlgorithm;
import org.gvsig.geoprocess.lib.api.GeoProcessLocator;
import org.gvsig.geoprocess.lib.sextante.SextanteGeoProcessManager;
import org.gvsig.geoprocess.lib.sextante.core.DefaultOutputFactory;
import org.gvsig.geoprocess.lib.sextante.dataObjects.FlyrVectIVectorLayer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import es.unex.sextante.core.GeoAlgorithm;
import es.unex.sextante.core.OutputObjectsSet;
import es.unex.sextante.core.ParametersSet;
import es.unex.sextante.exceptions.WrongOutputIDException;
import es.unex.sextante.exceptions.WrongParameterIDException;
import es.unex.sextante.outputs.Output;

/**
 *
 * @author Francisco Puga <fpuga@icarto.es>
 *
 *         <pre>
 * http://conocimientoabierto.es/usando-geoprocesos-en-gvsig-desde-java/878/
 * Add to pom
 * <dependency>
 * 	<groupId>org.gvsig</groupId>
 * 	<artifactId>org.gvsig.geoprocess.lib.api</artifactId>
 * 	<version>2.2.66</version>
 * </dependency>
 *
 * <dependency>
 * 	<groupId>org.gvsig</groupId>
 * 	<artifactId>org.gvsig.geoprocess.lib.sextante</artifactId>
 * 	<version>2.2.66</version>
 * </dependency>
 *
 * <dependency>
 * 	<groupId>org.gvsig</groupId>
 * 	<artifactId>org.gvsig.geoprocess.algorithm.intersection</artifactId>
 * 	<version>2.2.66</version>
 * </dependency>
 * Add to config
 * <depends plugin-name="org.gvsig.geoprocess.app.sextante"/>
 * </pre>
 *
 */
public class GeoProcessExampleExtension extends Extension {

	private static final Logger logger = LoggerFactory
			.getLogger(GeoProcessExampleExtension.class);

	private final static String INTERSECTION_LAYER_NAME = "inter";
	private final static String LAYER_NAME = "layer";

	@Override
	public void execute(String actionCommand) {
		PluginServices.getMDIManager().setWaitCursor();
		try {
			doExecute();
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		} finally {
			PluginServices.getMDIManager().restoreCursor();
		}
	}

	private void doExecute() {
		String ALG_NAME = "gvSIG-intersection";
		SextanteGeoProcessManager manager = (SextanteGeoProcessManager) GeoProcessLocator
				.getGeoProcessManager();
		HashMap<String, GeoAlgorithm> algs = manager.getAlgorithms();
		GeoAlgorithm alg = algs.get(ALG_NAME);
		try {
			setParams(alg);
			alg.execute(null, new DefaultOutputFactory(), null);
			doFinalActions(alg);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
	}

	private void setParams(GeoAlgorithm alg) throws WrongParameterIDException {
		ParametersSet params = alg.getParameters();

		FLyrVect interLyr = getLayer(INTERSECTION_LAYER_NAME);
		FlyrVectIVectorLayer inter = new FlyrVectIVectorLayer();
		inter.create(interLyr);

		FLyrVect layerLyr = getLayer(LAYER_NAME);
		FlyrVectIVectorLayer layer = new FlyrVectIVectorLayer();
		layer.create(layerLyr);

		params.getParameter(IntersectionAlgorithm.INTER).setParameterValue(
				inter);
		params.getParameter(IntersectionAlgorithm.LAYER).setParameterValue(
				layer);
		params.getParameter(IntersectionAlgorithm.SELECTGEOM_INPUT)
				.setParameterValue(false);
		params.getParameter(IntersectionAlgorithm.SELECTGEOM_OVERLAY)
				.setParameterValue(false);
	}

	protected FLyrVect getLayer(String name) {
		IView iView = (IView) PluginServices.getMDIManager().getActiveWindow();
		FLayers layers = iView.getMapControl().getMapContext().getLayers();
		return (FLyrVect) layers.getLayer(name);
	}

	private void doFinalActions(GeoAlgorithm alg) throws WrongOutputIDException {
		OutputObjectsSet outputSet = alg.getOutputObjects();
		Output output = outputSet.getOutput(IntersectionAlgorithm.RESULT_POL);
		Object outputObject = output.getOutputObject();
		System.out.println(outputObject);
	}

	@Override
	public boolean isEnabled() {
		IWindow iWindow = PluginServices.getMDIManager().getActiveWindow();
		return iWindow instanceof IView;
	}

	@Override
	public void initialize() {
	}

	@Override
	public boolean isVisible() {
		return true;
	}

}

