import Vue from 'vue';
import { mount } from '@vue/test-utils';
import App from "@/components/app.vue";

test("test App Component",function(){
  const wrapper = mount(App);
  expect(wrapper.text()).toBe('Hello World')
})
