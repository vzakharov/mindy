<template lang="pug">
  div
    h3.mb-4 {{ isLogin ? 'Log in to Mindy' : 'Mindy beta access' }}
    //- Login form
    b-form( @submit.prevent="$emit(mode)" :disabled="busy.authenticating" )
      b-form-group( label="Email" label-for="email" )
        b-form-input#email( v-model="propped.email" type="email" placeholder="Email" )
      b-form-group( v-if="mode=='signup'" label="Handle" label-for="slug" )
        b-form-input#slug( v-model="propped.slug" type="text" placeholder="Something short and memorable" )
      b-form-group( label="Password" label-for="password" )
        b-form-input#password( v-model="propped.password" type="password" placeholder="Password" )
      div.d-flex.flex-column.align-items-end
        b-button( type="submit" variant="primary" ) {{ isLogin ? 'Log in' : 'Request beta access' }}
        div.align-self-center.mt-4.text-muted
          | {{ isLogin ? 'Don’t' : 'Already' }} have an account? 
          span( href="/" style="cursor: pointer; text-decoration: underline;" 
              @click="propped.mode=isLogin ? 'signup' : 'login'"
            )
            | {{ isLogin ? 'Request beta access' : 'Log in' }}
    b-spinner( v-show="busy.authenticating" small type="grow")
</template>

<script lang="coffee">

  import updatePropsMixin from '~/plugins/mixins/updateProps'

  export default

    mixins: [
      updatePropsMixin
    ]

    props: [ 'email', 'password', 'busy', 'mode' ]

    computed:

      isLogin: -> @mode is 'login'

</script>