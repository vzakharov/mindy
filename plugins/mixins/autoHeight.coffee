# A mixin that automatically sets the height of the element so that it fills the remaining space of the page

import _ from 'lodash'
import log from '~/plugins/log'

# log.disable()

export default ( ref, { footerRef } = {} ) ->

  fit = ( element, footer ) ->

    # Get the element's top
    # log "Offset of", element, "is",
    offset = element.getBoundingClientRect().top

    # Get the footer's height
    # log "Height of", footer, "is",
    footerHeight = footer?.getBoundingClientRect().height || 0

    # Get the window's height
    # log "Height of window is",
    windowHeight = window.innerHeight

    # Set the element's height
    # log "Setting height of", element, "to",
    element.style.height = "#{windowHeight - offset - footerHeight - 1}px"

  data: ->

    autoHeight:
      observer: null

  mounted: ->

    { [ref]: element, [footerRef]: footer } = _.mapValues( @$refs, ( ref ) -> ref.$el ? ref )

    # Fit the element to the window
    do doFit = -> fit element, footer

    # Fit the element to the window on window resize
    window.addEventListener 'resize', _.debounce doFit, 100

    # ...and on element/footer offset change
    @autoHeight.observer?.disconnect()
    @autoHeight.observer = new MutationObserver doFit

    [ element, footer ].filter(_.identity).forEach ( element ) =>
      @autoHeight.observer.observe element, attributes: true, childList: true, characterData: true, subtree: true






