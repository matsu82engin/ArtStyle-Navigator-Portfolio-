import { mount } from '@vue/test-utils';
import Home from '@/pages/index.vue';
import Help from '@/pages/help.vue';
import About from '@/pages/about.vue';

// ホームページのテスト
describe('Home',() => {
 it("test static-pages-view-home response",function(){
  const wrapper = mount(Home);
  expect(wrapper.text()).toContain('This is the home page');
 });
});

// helpページのテスト
describe('Help', () => {
  it("test static-pages-view-help response", () => {
    const wrapper = mount(Help);
    expect(wrapper.text()).toContain('This is the help page');
  });
});

// about ページのテスト
describe('About', () => {
  it("test static-pages-view-about response", () => {
  const wrapper = mount(About);
  expect(wrapper.text()).toContain('This is the about page');
  });
});

