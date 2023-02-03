import createDataContext from './createDataContext';

const reducer = (state, action) => {
  switch (action.type) {
    case 'set_is_loading':
      return {
        ...state,
        is_loading: action.payload,
      };
    default:
      return state;
  }
};

const getDispatch = (dispatch) => () => {
  return dispatch;
};

const setIsLoading = (dispatch) => (loading) => {
  dispatch({ type: 'set_is_loading', payload: loading });
};

export const { Context, Provider } = createDataContext(
  reducer,
  {
    getDispatch,
    setIsLoading,
  },
  // state
  {
    is_loading: false,
  }
);
