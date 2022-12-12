<template lang="pug">

  //- A modal for entering the OpenAI API key (no cancel button)
  b-modal(
    ref="openAIKeyModal"
    title="Enter your OpenAI API key"
    hide-footer
    :no-close-on-backdrop="!openAIkey || !keyValid"
    :no-close-on-esc="!openAIkey || !keyValid"
    :hide-header-close="!openAIkey || !keyValid"
  )

    //- Clarification on what the API key is for
    h4 Why?
    p
      | This app uses the OpenAI API to generate texts.
      | We DO NOT store your API key anywhere on our servers.
      | You can get your own API key&nbsp;
      a(href="https://beta.openai.com/account/api-keys", target="_blank")
        | here
      | .

    //- The form
    b-form(@submit.prevent="checkKey()")
      b-form-group(
        label="OpenAI API key"
        label-for="openAIkey"
      )
        b-form-input#openAIkey(
          v-model="openAIkey"
          type="text"
          placeholder="sk-..."
          :disabled="checkingKey"
        )
      b-button(
        type="submit"
        variant="primary"
        :disabled="!openAIkey || checkingKey"
      )
        b-spinner(v-show="checkingKey" small type="grow")
        | {{ checkingKey ? 'Checking...' : 'Check and save' }}

</template>

<script lang="coffee">

  import axios from 'axios'
  import tryAction from '~/plugins/tryAction'
  import mixpanelMixin from '~/plugins/mixins/mixpanel'

  export default

    mixins: [
      tryAction
      mixpanelMixin
    ]

    props: [
      'value'
    ]
    
    data: ->

      console.log "OpenAIKeyModal value: #{@value}"

      openAIkey: @value
      checkingKey: false
      keyValid: !!@value
    
    methods:

      show: ->
        # show the modal
        @$refs.openAIKeyModal.show()

      hide: ->
        # hide the modal
        @$refs.openAIKeyModal.hide()

      checkKey: ->
        # check if the key is valid by sending a request to the OpenAI API
        @try 'checkingKey',
          =>
            console.log "Checking key #{@openAIkey}"
            await axios.post 'https://api.openai.com/v1/engines/text-ada-001/completions',
              prompt: 'Hello'
              max_tokens: 1
              ,
                headers:
                  Authorization: "Bearer #{@openAIkey}"

            # Show a toast message, emit the key and hide the modal
            @$bvToast.toast 'Yay, the key is valid! Enjoy the app!',
              title: 'Success'
              variant: 'success'
              autoHideDelay: 3000
            
            @keyValid = true
            @$emit 'input', @openAIkey
            @hide()
            @mixpanel.track 'OpenAI key validated'

          errorMessage: (error) =>
            # if the key is invalid, use an "Invalid API key" error message; otherwise return nothing (to use the default error message)
            error?.response?.status == 401 && 'Invalid API key'
          
          except: =>
            @mixpanel.track 'Error checking OpenAI key'

</script>