/* PITCH3 — Meta (Facebook/Instagram) Pixel
 * ----------------------------------------------------------------------------
 * ONE THING TO DO: paste Kyle's Pixel ID below, between the quotes.
 * Get it from  business.facebook.com  ->  Events Manager  ->  your Pixel (a
 * 15–16 digit number). Until a real ID is set, the pixel stays OFF so the live
 * site has no console noise.
 *
 * Standard events used across the site:
 *   PageView          every page (fired here)
 *   InitiateCheckout  when someone clicks a Stripe enrollment button (join.html)
 *   Lead              when someone clicks a "Free Call" CTA (join.html)
 *   Purchase          on the post-payment success page (join/success.html)
 * ----------------------------------------------------------------------------
 */
window.PITCH3_PIXEL_ID = "YOUR_PIXEL_ID"; // <-- paste Kyle's Pixel ID here

(function () {
  var id = window.PITCH3_PIXEL_ID;
  if (!id || id === "YOUR_PIXEL_ID") return; // no real ID yet -> stay off

  !(function (f, b, e, v, n, t, s) {
    if (f.fbq) return;
    n = f.fbq = function () {
      n.callMethod ? n.callMethod.apply(n, arguments) : n.queue.push(arguments);
    };
    if (!f._fbq) f._fbq = n;
    n.push = n;
    n.loaded = !0;
    n.version = "2.0";
    n.queue = [];
    t = b.createElement(e);
    t.async = !0;
    t.src = v;
    s = b.getElementsByTagName(e)[0];
    s.parentNode.insertBefore(t, s);
  })(window, document, "script", "https://connect.facebook.net/en_US/fbevents.js");

  fbq("init", id);
  fbq("track", "PageView");
})();

/* Safe helper so page scripts can fire events without worrying whether the
 * pixel is on yet. Usage:  PITCH3.track('Lead')  */
window.PITCH3 = window.PITCH3 || {};
window.PITCH3.track = function (event, params) {
  if (window.fbq) window.fbq("track", event, params || {});
};
