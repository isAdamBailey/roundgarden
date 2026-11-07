package io.adambailey.roundgarden;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;

import androidx.test.ext.junit.rules.ActivityScenarioRule;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

@RunWith(AndroidJUnit4.class)
public final class MainActivityTest {
    @Rule
    public ActivityScenarioRule<MainActivity> activityRule =
            new ActivityScenarioRule<>(MainActivity.class);

    @Test
    public void loadsBundledGameAndInitialRendererFrame() throws Exception {
        String gameReady = null;
        long deadline = System.nanoTime() + TimeUnit.SECONDS.toNanos(20);
        while (System.nanoTime() < deadline
                && !"\"Enter the garden|true\"".equals(gameReady)) {
            gameReady = evaluateJavascript(
                    "(document.querySelector('#startButton span')?.textContent ?? 'missing') + '|' "
                            + "+ (window.roundgardenRendererReady === true)");
            if (!"\"Enter the garden|true\"".equals(gameReady)) {
                Thread.sleep(250);
            }
        }
        assertEquals("\"Enter the garden|true\"", gameReady);
    }

    private String evaluateJavascript(String script) throws Exception {
        AtomicReference<String> result = new AtomicReference<>();
        CountDownLatch evaluationComplete = new CountDownLatch(1);
        activityRule.getScenario().onActivity(activity -> {
            WebView webView = findWebView(activity.getWindow().getDecorView());
            assertNotNull("Activity should contain its game WebView", webView);
            webView.evaluateJavascript(script, value -> {
                result.set(value);
                evaluationComplete.countDown();
            });
        });
        if (!evaluationComplete.await(5, TimeUnit.SECONDS)) {
            return null;
        }
        return result.get();
    }

    private static WebView findWebView(View view) {
        if (view instanceof WebView) {
            return (WebView) view;
        }
        if (view instanceof ViewGroup) {
            ViewGroup group = (ViewGroup) view;
            for (int index = 0; index < group.getChildCount(); index++) {
                WebView result = findWebView(group.getChildAt(index));
                if (result != null) {
                    return result;
                }
            }
        }
        return null;
    }
}
